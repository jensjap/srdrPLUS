schedule_file = "config/schedule.yml"

if File.exist?(schedule_file) && Sidekiq.server?
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end

CITATION_BATCH_SIZE = 1.freeze
#CITATION_BATCH_SIZE = 1000.freeze
