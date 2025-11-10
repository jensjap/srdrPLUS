# frozen_string_literal: true
class MlResultIngestService
  require "json"
  require "uri"

  def self.ingest_train_result!(project_id:, result_key:)
    obj = S3_BUCKET.object(result_key)
    raise "train result not found: #{result_key}" unless obj.exists?

    payload = JSON.parse(obj.get.body.read)
    state = payload.dig("status", "state") || "succeeded"
    raise "train result not succeeded (state=#{state})" unless state == "succeeded"

    model_ts = payload.dig("model", "timestamp") or raise "missing model.timestamp"

    raw_counts = payload.dig("training_summary", "counts_per_label") || {}
    counts = {}
    raw_counts.each { |k, v| counts[k.to_s] = v.to_i }

    project = Project.find(project_id)
    ml_model = project.ml_models.find_or_create_by!(timestamp: model_ts)

    %w[0 1].each do |cat|
      next unless counts[cat]
      rec = ml_model.training_data_infos.find_or_initialize_by(category: cat)
      rec.count = counts[cat]
      rec.save!
    end

    val_preds = payload.dig("training_summary", "metrics", "val_predictions")
    if val_preds.is_a?(Array) && val_preds.any?
      buffer = []
      val_preds.each do |vp|
        true_label = vp["true_label"]
        scores = vp["scores"]
        next unless (true_label == 0 || true_label == 1) && scores.is_a?(Array) && scores.size >= 2

        buffer << {
          ml_model_id: ml_model.id,
          label: true_label.to_s,
          score: scores[1].to_f,
          created_at: Time.current,
          updated_at: Time.current
        }

        if buffer.size >= 5_000
          ModelPerformance.insert_all(buffer)
          buffer.clear
        end
      end
      ModelPerformance.insert_all(buffer) if buffer.any?
    end

    ml_model
  end

  def self.ingest_predict_result!(project_id:, ml_model:, index_key: nil, single_key: nil)
    if index_key && S3_BUCKET.object(index_key).exists?
      index_payload = JSON.parse(S3_BUCKET.object(index_key).get.body.read)
      parts = index_payload["parts"] || []
      parts.each do |part|
        shard_key = s3_key_from_uri(part["path"])
        ingest_predict_result_shard!(project_id: project_id, ml_model: ml_model, shard_key: shard_key)
      end
      return true
    end

    if single_key && S3_BUCKET.object(single_key).exists?
      ingest_predict_result_shard!(project_id: project_id, ml_model: ml_model, shard_key: single_key)
      return true
    end

    false
  end

  def self.ingest_predict_result_shard!(project_id:, ml_model:, shard_key:)
    obj = S3_BUCKET.object(shard_key)
    raise "predict shard not found: #{shard_key}" unless obj.exists?

    payload = JSON.parse(obj.get.body.read)

    state = payload.dig("status", "state")
    raise "predict shard not succeeded (state=#{state})" if state.present? && state != "succeeded"

    pid_in_payload = payload.dig("job", "project_id")
    if pid_in_payload && pid_in_payload.to_i != project_id.to_i
      raise "project_id mismatch in shard: #{pid_in_payload} != #{project_id}"
    end

    preds = payload["predictions"] || payload["items"] || []
    return 0 if preds.empty?

    missing_ids = preds.select { |p| p["citations_project_id"].blank? }
                      .map { |p| p["citation_id"] }
                      .compact
                      .uniq

    cp_map = {}
    if missing_ids.any?
      cp_map = CitationsProject
                .where(project_id: project_id, citation_id: missing_ids)
                .pluck(:citation_id, :id)
                .to_h
    end

    skipped = 0
    rows = preds.filter_map do |p|
      cp_id = p["citations_project_id"] || cp_map[p["citation_id"]]
      unless cp_id
        skipped += 1
        next
      end
      { citations_project_id: cp_id, ml_model_id: ml_model.id, score: p["score"].to_f,
        created_at: Time.current, updated_at: Time.current }
    end

    Rails.logger.warn("[PredictIngest] shard=#{shard_key} skipped_without_cp=#{skipped}") if skipped > 0
    return 0 if rows.empty?

    adapter = ActiveRecord::Base.connection.adapter_name.downcase

    if MlPrediction.respond_to?(:upsert_all)
      rows.each_slice(5_000) do |chunk|
        payload = chunk.map { |r| r.merge(created_at: Time.current, updated_at: Time.current) }

        if adapter.include?("mysql")
          MlPrediction.upsert_all(payload)
        else
          MlPrediction.upsert_all(
            payload,
            unique_by: :index_ml_predictions_on_citations_project_id_and_ml_model_id
          )
        end
      end
    else
      rows.each_slice(5_000) do |chunk|
        begin
          MlPrediction.insert_all(chunk.map { |r| r.merge(created_at: Time.current, updated_at: Time.current) })
        rescue ActiveRecord::RecordNotUnique
          chunk.each do |r|
            begin
              MlPrediction.insert_all([r.merge(created_at: Time.current, updated_at: Time.current)])
            rescue ActiveRecord::RecordNotUnique
            end
          end
        end
      end
    end

    rows.size
  end

  def self.s3_key_from_uri(uri_or_key)
    return uri_or_key if uri_or_key !~ %r{^s3://}i
    URI(uri_or_key).path.sub(%r{^/}, "")
  end
end
