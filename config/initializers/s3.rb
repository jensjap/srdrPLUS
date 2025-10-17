# frozen_string_literal: true
require "aws-sdk-s3"

credentials =
  if Rails.env.production?
    nil
  else
    Aws::Credentials.new(ENV.fetch("S3_ACCESS_KEY_ID"), ENV.fetch("S3_SECRET_ACCESS_KEY"))
  end

client_opts = {
  region: ENV.fetch("S3_REGION", "us-east-1")
}
client_opts[:credentials] = credentials if credentials
client_opts[:endpoint] = ENV["S3_ENDPOINT"] if ENV["S3_ENDPOINT"].present?
client_opts[:force_path_style] = (ENV["S3_FORCE_PATH_STYLE"] == "true") if ENV["S3_ENDPOINT"].present?

S3_CLIENT   = Aws::S3::Client.new(**client_opts)
S3_RESOURCE = Aws::S3::Resource.new(client: S3_CLIENT)
S3_BUCKET   = S3_RESOURCE.bucket(ENV.fetch("S3_BUCKET"))

if !Rails.env.production?
  begin
    S3_CLIENT.create_bucket(bucket: S3_BUCKET.name) unless S3_BUCKET.exists?
  rescue Aws::S3::Errors::BucketAlreadyOwnedByYou, Aws::S3::Errors::BucketAlreadyExists
  end
end
