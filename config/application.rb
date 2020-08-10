require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SrdrPLUS
  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Use a real queuing backend for Active Job (and separate queues per environment)
    config.active_job.queue_adapter     = :sidekiq
    #config.active_job.queue_name_prefix = "srdrPLUS_#{ Rails.env }"
  end
end

if Rails.env.production?
  Raven.configure do |config|
    config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    config.dsn = Rails.application.credentials.dig(:sentry)
  end
end