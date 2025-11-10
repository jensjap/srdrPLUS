# frozen_string_literal: true
class MlS3ResultIngestor
  RESULTS_PREFIX = ENV["S3_RESULTS_DIR"].presence || "results"
  ARCHIVE_PREFIX = ENV["S3_ARCHIVE_PREFIX"].presence || "archive"

  def self.ingest_all_trains!
    keys = list_keys(File.join(RESULTS_PREFIX, "train/"), suffix: ".json")
    keys.each do |key|
      pid = key[/train_result_proj-(\d+)_/, 1]&.to_i
      job_id = extract_job_id(key)
      next unless pid && job_id

      unless MlS3ActiveMarkerService.active?(pid, :train, job_id)
        archive_object(key)
        Rails.logger.info("[IngestTrain] skip(pid=#{pid}, job=#{job_id}) not active")
        next
      end

      payload = read_payload(key)
      state   = payload.dig("status", "state").to_s.presence || "succeeded"
      if state != "succeeded"
        MlS3ActiveMarkerService.write_failed!(job_id)
        archive_object(key, subdir: "failed")
        MlS3ActiveMarkerService.delete_active!(pid, :train)
        Rails.logger.warn("[IngestTrain] pid=#{pid} job=#{job_id} state=#{state} archived->failed/")
        next
      end

      ml_model = MlResultIngestService.ingest_train_result!(project_id: pid, result_key: key)
      MlS3ActiveMarkerService.write_ingested!(job_id)
      archive_object(key)
      Rails.logger.info("[IngestTrain] pid=#{pid} job=#{job_id} model=#{ml_model.id}")
    rescue => e
      MlS3ActiveMarkerService.write_failed!(job_id) if job_id
      archive_object(key, subdir: "failed") if key
      MlS3ActiveMarkerService.delete_active!(pid, :train) if pid
      Rails.logger.error("[IngestTrain] key=#{key} #{e.class} #{e.message}")
    end
  end

  def self.ingest_all_predicts!
    singles = list_keys(File.join(RESULTS_PREFIX, "predict/"), suffix: ".json").reject { |k| k.end_with?("_index.json") }
    indices = list_keys(File.join(RESULTS_PREFIX, "predict/"), suffix: "_index.json")
    (singles + indices).each do |key|
      pid    = key[/predict_result_proj-(\d+)_/, 1]&.to_i
      job_id = extract_job_id(key)
      next unless pid && job_id

      unless MlS3ActiveMarkerService.active?(pid, :predict, job_id)
        archive_object(key)
        Rails.logger.info("[IngestPredict] skip(pid=#{pid}, job=#{job_id}) not active")
        next
      end

      payload = read_payload(key)
      state   = payload.dig("status", "state").to_s.presence || "succeeded"

      if state != "succeeded"
        err_code = payload.dig("error", "code")
        MlS3ActiveMarkerService.write_failed!(job_id)
        archive_object(key, subdir: "failed")
        MlS3ActiveMarkerService.delete_active!(pid, :predict)

        if %w[NO_TARGET NO_MODEL].include?(err_code)
          Rails.logger.warn("[IngestPredict] pid=#{pid} job=#{job_id} failed(NO_TARGET): archived->failed/, skip re-enqueue")
        else
          Rails.logger.warn("[IngestPredict] pid=#{pid} job=#{job_id} failed(#{err_code || 'unknown'}): archived->failed/ and retrain enqueue")
          MlS3RequestEnqueuer.enqueue_force_retrain!(project_id: pid)
        end
        next
      end

      qg = payload["quality_gate"] || {}
      if qg.key?("passed") && !qg["passed"]
        MlS3ActiveMarkerService.write_failed!(job_id)
        archive_object(key, subdir: "failed/quality")
        MlS3ActiveMarkerService.delete_active!(pid, :predict)
        Rails.logger.warn("[IngestPredict] pid=#{pid} job=#{job_id} quality=FAILED (#{qg["reason"] || 'no reason'}) "\
                          "-> archived->failed/quality and retrain enqueue")
        MlS3RequestEnqueuer.enqueue_force_retrain!(project_id: pid)
        next
      end

      model_ts = payload.dig("model", "timestamp")
      ml_model = if model_ts.present?
                   Project.find(pid).ml_models.find_by!(timestamp: model_ts)
                 else
                   Project.find(pid).ml_models.order(created_at: :desc).first
                 end

      if key.end_with?("_index.json")
        MlResultIngestService.ingest_predict_result!(project_id: pid, ml_model: ml_model, index_key: key, single_key: nil)
      else
        MlResultIngestService.ingest_predict_result!(project_id: pid, ml_model: ml_model, index_key: nil, single_key: key)
      end

      MlS3ActiveMarkerService.write_ingested!(job_id)
      archive_object(key)
      Rails.logger.info("[IngestPredict] pid=#{pid} job=#{job_id} done")
    rescue => e
      MlS3ActiveMarkerService.write_failed!(job_id) if job_id
      archive_object(key, subdir: "failed") if key
      MlS3ActiveMarkerService.delete_active!(pid, :predict) if pid
      Rails.logger.error("[IngestPredict] key=#{key} #{e.class} #{e.message} -> failed & retrain enqueue")
      MlS3RequestEnqueuer.enqueue_force_retrain!(project_id: pid) if pid
    end
  end

  def self.list_keys(prefix, suffix:)
    resp = S3_BUCKET.client.list_objects_v2(bucket: S3_BUCKET.name, prefix: prefix)
    (resp.contents || []).map(&:key).select { |k| k.end_with?(suffix) }
  end

  def self.extract_job_id(key)
    key[/_(\h{8}-(\h{4}-){3}\h{12})\.json$/, 1] || key[/_(\w+)\.json$/, 1]
  end

  def self.read_payload(key)
    JSON.parse(S3_BUCKET.object(key).get.body.read)
  rescue
    {}
  end

  def self.archive_object(key, subdir: nil)
    suffix = key.split("/", 2).last
    base   = File.join(ARCHIVE_PREFIX, Time.now.utc.strftime("%Y/%m/%d/"))
    dst    = subdir.present? ? File.join(base, subdir, suffix) : File.join(base, suffix)
    S3_BUCKET.object(dst).copy_from(copy_source: "#{S3_BUCKET.name}/#{key}")
    S3_BUCKET.object(key).delete
  end
end
