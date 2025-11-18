return unless Rails.env.production?

module DatabaseCredentialRefresh
  def checkout
    super
  rescue ActiveRecord::DatabaseConnectionError, Mysql2::Error::ConnectionError => e
    if e.message.include?('Access denied') || e.message.include?('username/password')
      Rails.logger.warn "Database connection failed with auth error: #{e.message}"
      Rails.logger.info "Attempting to refresh credentials from AWS Secrets Manager..."

      if refresh_credentials_and_reconnect
        Rails.logger.info "Credentials refreshed successfully, retrying connection..."
        super
      else
        Rails.logger.error "Failed to refresh credentials, raising original error"
        raise
      end
    else
      raise
    end
  end

  private

  def refresh_credentials_and_reconnect
    return false unless ENV['AWS_REGION'] && ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'] && ENV['AWS_SECRET_NAME']

    begin
      require 'aws-sdk-secretsmanager'

      secrets_manager_client = Aws::SecretsManager::Client.new(
        region: ENV['AWS_REGION'],
        credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
      )

      response = secrets_manager_client.get_secret_value(secret_id: ENV['AWS_SECRET_NAME'])
      new_credentials = JSON.parse(response.secret_string)

      if defined?(DATABASE_CREDENTIALS) && DATABASE_CREDENTIALS.is_a?(Hash)
        DATABASE_CREDENTIALS.replace(new_credentials)
      else
        Object.const_set('DATABASE_CREDENTIALS', new_credentials)
      end

      Rails.logger.info "DATABASE_CREDENTIALS updated with new values"

      # Disconnect all existing connections
      ActiveRecord::Base.connection_pool.disconnect!

      # Establish new connection with refreshed credentials
      ActiveRecord::Base.establish_connection

      true
    rescue Aws::SecretsManager::Errors::ServiceError => e
      Rails.logger.error "Failed to fetch credentials from AWS Secrets Manager: #{e.message}"
      false
    rescue StandardError => e
      Rails.logger.error "Unexpected error during credential refresh: #{e.class} - #{e.message}"
      false
    end
  end
end

ActiveRecord::ConnectionAdapters::ConnectionPool.prepend(DatabaseCredentialRefresh)

Rails.logger.info "Database credential refresh module loaded for production environment"
