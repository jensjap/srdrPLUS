web: bundle exec rails s --port=$PORT
redis: redis-server
worker1: bundle exec sidekiq -q default
worker2: bundle exec sidekiq -q mailers
