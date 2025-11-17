# frozen_string_literal: true
require "aws-sdk-s3"

# Skip S3 initialization if required environment variables are not present
# This allows Docker builds and asset precompilation to succeed without S3 config
if ENV["S3_BUCKET"].blank?
  Rails.logger.info "S3_BUCKET not configured, skipping S3 initialization"
  S3_CLIENT = nil
  S3_RESOURCE = nil
  S3_BUCKET = nil
else
  credentials =
    if Rails.env.production?
      nil
    else
      # Only require credentials in non-production if they're provided
      if ENV["S3_ACCESS_KEY_ID"].present? && ENV["S3_SECRET_ACCESS_KEY"].present?
        Aws::Credentials.new(ENV["S3_ACCESS_KEY_ID"], ENV["S3_SECRET_ACCESS_KEY"])
      else
        nil
      end
    end

  client_opts = {
    region: ENV.fetch("S3_REGION", "us-east-1")
  }
  client_opts[:credentials] = credentials if credentials
  client_opts[:endpoint] = ENV["S3_ENDPOINT"] if ENV["S3_ENDPOINT"].present?
  client_opts[:force_path_style] = (ENV["S3_FORCE_PATH_STYLE"] == "true") if ENV["S3_ENDPOINT"].present?

  S3_CLIENT   = Aws::S3::Client.new(**client_opts)
  S3_RESOURCE = Aws::S3::Resource.new(client: S3_CLIENT)
  S3_BUCKET   = S3_RESOURCE.bucket(ENV["S3_BUCKET"])

  # Auto-create bucket in non-production environments
  if !Rails.env.production?
    begin
      S3_CLIENT.create_bucket(bucket: S3_BUCKET.name) unless S3_BUCKET.exists?
    rescue Aws::S3::Errors::BucketAlreadyOwnedByYou, Aws::S3::Errors::BucketAlreadyExists
      # Bucket already exists, which is fine
    end
  end
end
