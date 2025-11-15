# frozen_string_literal: true
class MlRequestPackagingService
  require "securerandom"
  require "json"

  REQUESTS_PREFIX = ENV["S3_REQUESTS_PREFIX"].presence || "requests"
  RESULTS_PREFIX_URI = ENV["S3_RESULTS_PREFIX"].presence || "s3://#{ENV.fetch('S3_BUCKET')}/results/"

  def self.put_json_to_s3(key, payload)
    S3_BUCKET.put_object(
      key: key,
      body: JSON.pretty_generate(payload),
      content_type: "application/json; charset=utf-8"
    )
    "s3://#{ENV['S3_BUCKET']}/#{key}"
  end

  def self.iso_now = Time.now.utc.iso8601
  def self.compact_ts(t) = t.gsub(/[:\-]/, "").gsub("T","").gsub("Z","Z")

  def self.upload_train_citation_map(project_id, schema_version: "1.0", precomputed_items: nil)
    job_id = SecureRandom.uuid
    created_at = iso_now
    ts_part = compact_ts(created_at)
    items = precomputed_items || MachineLearningDataSupplyingService.get_labeled_id_label(project_id)

    payload = {
      schema_version: schema_version,
      job: {
        job_id: job_id, type: "train", project_id: project_id, method: "abstract_screenings",
        created_at: created_at, requested_by: APP_INSTANCE_ID
      },
      data_spec: {
        source: { mode: "id_label_map" },
        counts: { total_items: items.size, labels: items.group_by { |h| h[:label] }.transform_values(&:size) }
      },
      train_items: items,
      io: { result_prefix: RESULTS_PREFIX_URI, shard_size: 0 }
    }

    key = File.join(REQUESTS_PREFIX, "train", "trained_proj-#{project_id}_#{ts_part}_#{job_id}.json")
    uri = put_json_to_s3(key, payload)
    { job_id: job_id, request_key: key, request_uri: uri, total_items: items.size }
  end

  def self.upload_predict_citation_ids(project_id, model_timestamp:, allow_latest_if_missing: false,
                                       schema_version: "1.0", shard_size: 20_000, precomputed_ids: nil)
    job_id = SecureRandom.uuid
    created_at = iso_now
    ts_part = compact_ts(created_at)
    citation_ids = precomputed_ids || MachineLearningDataSupplyingService.get_unlabeled_citation_ids(project_id)

    payload = {
      schema_version: schema_version,
      job: { job_id: job_id, type: "predict", project_id: project_id, method: "abstract_screenings",
             created_at: created_at, requested_by: APP_INSTANCE_ID },
      predict_spec: {
        model_locator: { by: "timestamp", timestamp: model_timestamp, allow_latest_if_missing: allow_latest_if_missing },
        target: { mode: "ids", citation_ids: citation_ids },
        quality_gate: { enabled: true, score_threshold: 0.9, percentage_threshold: 20, low_mean_autopass: 0.05, stddev_min: 0.01 },
        batching: { max_rows_per_batch: 50_000 }
      },
      io: { result_prefix: RESULTS_PREFIX_URI, shard_size: shard_size }
    }

    key = File.join(REQUESTS_PREFIX, "predict", "untrained_proj-#{project_id}_#{ts_part}_#{job_id}.json")
    uri = put_json_to_s3(key, payload)
    { job_id: job_id, request_key: key, request_uri: uri, total_items: citation_ids.size }
  end
end
