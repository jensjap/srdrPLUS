if Rails.env.production?
  require 'faraday_middleware/aws_sigv4'

  Searchkick.client = OpenSearch::Client.new(
    url: ENV["OPENSEARCH_URL"],
    transport_options: {
      headers: { content_type: "application/json" },
      request: { timeout: 300, open_timeout: 10 }  # 5 minute timeout for bulk operations
    },
    retry_on_failure: true,
    retry_on_status: [429, 502, 503, 504],
    max_retries: 20,
    resurrect_after: 10,
    request_timeout: 300,  # 5 minutes for requests
    timeout: 300  # Overall timeout
  ) do |f|
    f.request :aws_sigv4,
      service: "es",
      region: ENV["AWS_REGION"],
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
        },
        request: { timeout: 300, open_timeout: 10 }
      },
      request_timeout: 300,
      timeout: 300
    }
  end
end