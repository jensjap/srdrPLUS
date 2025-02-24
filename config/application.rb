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
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Use a real queuing backend for Active Job (and separate queues per environment)
    config.active_job.queue_adapter = :sidekiq
    # config.active_job.queue_name_prefix = "srdrPLUS_#{ Rails.env }"

    #config.autoload_paths += ["#{config.root}/services"]
    config.autoload_paths += ["#{config.root}/lib"]
    config.autoload_paths += Dir[Rails.root.join('app', 'services', '**', '*')]

    # Restriction of Rendered UI Layers or Frames.
    config.action_dispatch.default_headers['Content-Security-Policy'] = "frame-ancestors 'self';"
    config.action_dispatch.default_headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    config.action_dispatch.default_headers['X-Frame-Options'] = 'SAMEORIGIN'
    config.action_dispatch.default_headers['X-XSS-Protection'] = '1; mode=block'

    config.aws_region = ENV['AWS_REGION']
  end
end

if Rails.env.production?
  Sentry.init do |config|
    config.dsn = Rails.application.credentials.dig(:sentry)
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    config.before_send = lambda do |event, _hint|
      filter.filter(event.to_hash)
    end
  end
end
