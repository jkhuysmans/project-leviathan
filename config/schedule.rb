# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
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

env :PATH, ENV['PATH']

Time.zone = 'UTC'

every 1.day, at: '00:00:10' do
  rake 'websocket:scratch_by_minute RAILS_ENV=production'
  rake 'klines_websocket:scratch_by_minute RAILS_ENV=production'
  rake 'klines_refresh:scratch_by_minute RAILS_ENV=production'
end