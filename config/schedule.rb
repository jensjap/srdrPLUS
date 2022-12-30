# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, './log/cron_log.log'
env :PATH, ENV['PATH']
# env :SRDRPLUS_DATABASE_USERNAME, ENV['SRDRPLUS_DATABASE_USERNAME']
# env :SRDRPLUS_DATABASE_PASSWORD, ENV['SRDRPLUS_DATABASE_PASSWORD']

every 30.minutes do
  runner 'HealthMonitorService.perform_check'
end
every 60.minutes do
  runner 'OrderableCleanupService.perform_check'
end
