#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

export RAILS_ENV=production
export RAILS_SERVE_STATIC_FILES=true
bundle exec rails s -b 0.0.0.0
