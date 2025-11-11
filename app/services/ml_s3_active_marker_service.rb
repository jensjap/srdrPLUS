# frozen_string_literal: true
class MlS3ActiveMarkerService
  MARKERS_PREFIX = ENV["S3_MARKERS_PREFIX"].presence || "markers"

  # kind: :train / :predict
  def self.active_job_id(project_id, kind)
    key = marker_key(project_id, kind)
    obj = S3_BUCKET.object(key)
    return nil unless obj.exists?
    obj.get.body.read.strip.presence
  end

  def self.active?(project_id, kind, job_id)
    active_job_id(project_id, kind) == job_id.to_s
  end

  def self.write_active!(project_id, kind, job_id)
    S3_BUCKET.put_object(
      key: marker_key(project_id, kind),
      body: job_id.to_s,
      content_type: "text/plain"
    )
  end

  def self.delete_active!(project_id, kind)
    S3_BUCKET.object(marker_key(project_id, kind)).delete
  end

  def self.write_ingested!(job_id)
    S3_BUCKET.put_object(
      key: File.join(MARKERS_PREFIX, "#{job_id}.result.ingested"),
      body: "",
      content_type: "text/plain"
    )
  end

  def self.ingested?(job_id)
    S3_BUCKET.object(File.join(MARKERS_PREFIX, "#{job_id}.result.ingested")).exists?
  end

  def self.write_failed!(job_id)
    S3_BUCKET.put_object(
      key: File.join(MARKERS_PREFIX, "#{job_id}.result.failed"),
      body: "",
      content_type: "text/plain"
    )
  end

  def self.marker_key(project_id, kind)
    case kind.to_sym
    when :train   then File.join(MARKERS_PREFIX, "project-#{project_id}.active_train_job")
    when :predict then File.join(MARKERS_PREFIX, "project-#{project_id}.active_predict_job")
    else raise "unknown kind: #{kind}"
    end
  end
end
