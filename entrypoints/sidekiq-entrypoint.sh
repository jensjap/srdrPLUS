#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

export RAILS_ENV=production
bundle exec sidekiq -C config/sidekiq.yml
