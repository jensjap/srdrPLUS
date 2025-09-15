# frozen_string_literal: true
return if Rails.env.production?

require "aws-sdk-s3"

S3_CREDENTIALS = Aws::Credentials.new(
  ENV.fetch("S3_ACCESS_KEY_ID"),
  ENV.fetch("S3_SECRET_ACCESS_KEY")
)

S3_CLIENT = Aws::S3::Client.new(
  endpoint: ENV["S3_ENDPOINT"],
  region:   ENV.fetch("S3_REGION", "us-east-1"),
  credentials: S3_CREDENTIALS,
  force_path_style: ENV["S3_FORCE_PATH_STYLE"] == "true"
)

S3_RESOURCE = Aws::S3::Resource.new(client: S3_CLIENT)
S3_BUCKET   = S3_RESOURCE.bucket(ENV.fetch("S3_BUCKET"))

begin
  unless S3_BUCKET.exists?
    S3_CLIENT.create_bucket(bucket: ENV.fetch("S3_BUCKET"))
  end
rescue Aws::S3::Errors::BucketAlreadyOwnedByYou, Aws::S3::Errors::BucketAlreadyExists
  # ignore
end
