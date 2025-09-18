if Rails.env.production?
  require 'faraday/aws_sigv4'

  Searchkick.client = OpenSearch::Client.new(
    url: ENV["OPENSEARCH_URL"],
    transport_options: {
      headers: { content_type: "application/json" }
    }
  ) do |f|
    f.request :aws_sigv4,
      service: "es",
      region: "your-aws-region",
      access_key_id: ENV["AWS_ACCESS_KEY_ID"],
      secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
    f.adapter Faraday.default_adapter
  end
else
  if defined?(Searchkick)
    Searchkick.client_options = {
      transport_options: {
        ssl: {
          ca_file: "/app/certs/ca/ca.crt"
        }
      }
    }
  end
end