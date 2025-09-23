if Rails.env.production?
  require 'faraday_middleware/aws_sigv4'

  Searchkick.client = OpenSearch::Client.new(
    url: ENV['OPENSEARCH_URL'],
    transport_options: {
      headers: { content_type: 'application/json' }
    }
  ) do |f|
    f.request :aws_sigv4,
              service: 'es',
              region: ENV['AWS_REGION'],
              access_key_id: ENV['AWS_ACCESS_KEY_ID'],
              secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    f.adapter Faraday.default_adapter
  end
elsif defined?(Searchkick)
  Searchkick.client_options = {
    transport_options: {
      ssl: {
        ca_file: '/app/certs/ca/ca.crt'
      }
    }
  }
end
