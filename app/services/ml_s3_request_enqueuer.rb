# frozen_string_literal: true
class MlS3RequestEnqueuer
  REQUESTS_PREFIX = ENV["S3_REQUESTS_PREFIX"].presence || "requests"
  TRAIN_DIR = File.join(REQUESTS_PREFIX, "train")
  PREDICT_DIR = File.join(REQUESTS_PREFIX, "predict")
  RESULTS_PREFIX = ENV["S3_RESULTS_PREFIX"].presence || "s3://#{ENV.fetch('S3_BUCKET')}/results/"
  MARKERS_PREFIX = ENV["S3_MARKERS_PREFIX"].presence || "markers"

  def self.enqueue_train_and_predict_for_project!(project_id:, threshold_new_labels:, min_per_class: 1)
    project = Project.find(project_id)
    return unless project.abstract_screening_results.exists?

    new_labeled = MachineLearningDataSupplyingService.get_labeled_abstract_since_last_train(project.id)

    last_train_time  = project.ml_models.order(created_at: :desc).first&.created_at
    days_since_last  = (Time.zone.now - (last_train_time || Time.zone.at(0))) / 1.day
    should_train = project.force_training ||
                   new_labeled.size >= threshold_new_labels ||
                   (new_labeled.size > 0 && days_since_last >= 7)
    return unless should_train

    items = MachineLearningDataSupplyingService.get_labeled_id_label(project.id)
    stat  = label_stats(items, min_per_class: min_per_class)

    unless stat[:ok]
      Rails.logger.warn("[Enqueue] pid=#{project.id} skip: label imbalance counts=#{stat[:counts].inspect} min_per_class=#{min_per_class}")
      return
    end

    purge_old_requests!(project_id)

    train_req = MlRequestPackagingService.upload_train_citation_map(project.id, precomputed_items: items)
    write_active_marker(project_id, :train, train_req[:job_id])

    ids = MachineLearningDataSupplyingService.get_unlabeled_citation_ids(project.id)
    predict_req = MlRequestPackagingService.upload_predict_citation_ids(
      project.id,
      model_timestamp: nil,
      allow_latest_if_missing: true,
      precomputed_ids: ids
    )
    write_active_marker(project_id, :predict, predict_req[:job_id])

    Rails.logger.info("[Enqueue] pid=#{project.id} train_job=#{train_req[:job_id]} predict_job=#{predict_req[:job_id]} "\
                      "label_counts=#{stat[:counts].inspect} unlabeled=#{ids.size}")
    { train_job_id: train_req[:job_id], predict_job_id: predict_req[:job_id] }
  end

  def self.enqueue_all!(threshold_new_labels:, projects_scope: Project.all, min_per_class: (ENV["ML_MIN_PER_CLASS"] || 1).to_i)
    projects_scope.find_each do |project|
      enqueue_train_and_predict_for_project!(
        project_id: project.id,
        threshold_new_labels: threshold_new_labels,
        min_per_class: min_per_class
      )
    rescue => e
      Rails.logger.error("[EnqueueAll] pid=#{project.id} #{e.class} #{e.message}")
    end
  end

  def self.label_stats(items, min_per_class:)
    counts = items.group_by { |h| h[:label] }.transform_values(&:size)
    ok = counts.key?('0') && counts.key?('1') &&
         counts['0'].to_i >= min_per_class &&
         counts['1'].to_i >= min_per_class
    { counts: counts, ok: ok }
  end

  def self.purge_old_requests!(project_id)
    list_keys(File.join(TRAIN_DIR, "trained_proj-#{project_id}_")).each { |k| delete_key(k) }
    list_keys(File.join(PREDICT_DIR, "untrained_proj-#{project_id}_")).each { |k| delete_key(k) }

    delete_key(File.join(MARKERS_PREFIX, "project-#{project_id}.active_train_job"))
    delete_key(File.join(MARKERS_PREFIX, "project-#{project_id}.active_predict_job"))
  end

  def self.write_active_marker(project_id, kind, job_id)
    name = case kind
           when :train then "project-#{project_id}.active_train_job"
           when :predict then "project-#{project_id}.active_predict_job"
           else raise "unknown kind #{kind}"
           end
    S3_BUCKET.put_object(
      key: File.join(MARKERS_PREFIX, name),
      body: job_id.to_s,
      content_type: "text/plain"
    )
  end

  def self.list_keys(prefix)
    resp = S3_BUCKET.client.list_objects_v2(bucket: S3_BUCKET.name, prefix: prefix)
    (resp.contents || []).map(&:key)
  end

  def self.delete_key(key)
    S3_BUCKET.object(key).delete if S3_BUCKET.object(key).exists?
  end
end
