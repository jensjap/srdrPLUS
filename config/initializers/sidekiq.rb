CITATION_BATCH_SIZE = 1.freeze
#CITATION_BATCH_SIZE = 1000.freeze

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_SERVER_URL"] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_SERVER_URL"] }
end

schedule_file = "config/schedule.yml"

Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDIS_SERVER'] }
end if ENV['REDIS_SERVER'].present?

Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDIS_CLIENT'] }
end if ENV['REDIS_CLIENT'].present?

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
