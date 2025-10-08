return unless Rails.env.production? && ENV['AWS_REGION'] && ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'] && ENV['AWS_SECRET_NAME']

require 'aws-sdk-secretsmanager'

Aws.config.update({
  region: ENV['AWS_REGION'],
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
})

# Create a Secrets Manager client
secrets_manager_client = Aws::SecretsManager::Client.new

# Example: Fetch a secret
secret_name = ENV['AWS_SECRET_NAME']
begin
  response = secrets_manager_client.get_secret_value(secret_id: secret_name)
  secret = response.secret_string
  DATABASE_CREDENTIALS = JSON.parse(secret)
rescue Aws::SecretsManager::Errors::ServiceError => e
  puts "Error fetching secret: #{e.message}"
end
