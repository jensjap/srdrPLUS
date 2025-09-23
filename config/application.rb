require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SrdrPlus
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Use a real queuing backend for Active Job (and separate queues per environment)
    config.active_job.queue_adapter = :sidekiq

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    #
    # Legacy
    config.autoload_paths += ["#{config.root}/lib"]
    config.autoload_paths += Dir[Rails.root.join('app', 'services', '**', '*')]

    # Restriction of Rendered UI Layers or Frames.
    config.action_dispatch.default_headers['Content-Security-Policy'] = "frame-ancestors 'self';"
    config.action_dispatch.default_headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
    config.action_dispatch.default_headers['X-Frame-Options'] = 'SAMEORIGIN'
    config.action_dispatch.default_headers['X-XSS-Protection'] = '1; mode=block'

    config.aws_region = ENV['AWS_REGION'] if Rails.env.production?
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
