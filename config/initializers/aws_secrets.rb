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
  Rails.logger.info "Successfully loaded DATABASE_CREDENTIALS from AWS Secrets Manager"
rescue Aws::SecretsManager::Errors::ServiceError => e
  Rails.logger.error "CRITICAL: Failed to fetch DATABASE_CREDENTIALS from AWS Secrets Manager: #{e.message}"
  Rails.logger.error "Database connections may fail! The credential refresh module will attempt to recover."
  puts "Error fetching secret: #{e.message}"
end

# Verify credentials were loaded
if !defined?(DATABASE_CREDENTIALS) || DATABASE_CREDENTIALS.nil?
  Rails.logger.fatal "DATABASE_CREDENTIALS is not set! Initial database connection will likely fail."
  Rails.logger.fatal "The credential refresh module will attempt to fetch credentials on first connection failure."
end
