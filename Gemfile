source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 7.0.3'

# Use mysql as the database for Active Record
gem 'mysql2'
# Use Puma as the app server
gem 'puma'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.10.1'
# Use Redis adapter to run Action Cable in production
gem 'redis'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'dotenv-rails'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'simplecov', require: false
end

group :development do
  gem 'bullet'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Annotate Models
  gem 'annotate'

  # Formatted console logs
  gem 'awesome_print'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

## Non-default gems.

# Use Zurb Foundation as Front-End Framework
gem 'autoprefixer-rails'
gem 'foundation-icons-sass-rails'
gem 'foundation-rails'

# Prettier templates.
gem 'slim-rails'

# Simplified forms.
gem 'cocoon'
gem 'country_select'
gem 'simple_form'

# Authentication.
gem 'devise'
gem 'omniauth'
gem 'remotipart', github: 'mshibuya/remotipart'

# Flash messages.
gem 'toastr_rails'

# Versioning of models + soft-delete.
gem 'paranoia', '~>2.2'

# Create lots of data.
gem 'faker', github: 'stympy/faker'

# Access ruby data in JavaScript.
gem 'gon'

# Pagination.
gem 'kaminari'

# CORS.
gem 'rack-cors'

# Help DRY up code.
gem 'responders'

# Api documentation.
gem 'apipie-rails'

# Background jobs.
gem 'sidekiq'

# Spreadsheet generation.
gem 'caxlsx'
gem 'caxlsx_rails'

# Spreadsheet reading.
gem 'rubyXL', '~> 1.2.10'
gem 'zip-zip'

# Searching with Elasticsearch.
gem 'elasticsearch', '< 7.14'
gem 'searchkick'

gem 'searchjoy'

gem 'passenger'

# bioruby for pubmed queries.
gem 'bio'

# for parsing ris files.
gem 'ref_parsers', '~> 0.2.0'

# breadcrumbs.
gem 'breadcrumbs_on_rails'

# authorizations.
gem 'pundit'

# List reordering, Drag & Drop.
gem 'sortable-rails'

# Simple calls to external API.
gem 'httparty'

# New for Rails 5.2.
gem 'bootsnap'

# Access to AWS S3 Cloud Storage.
gem 'aws-sdk-s3', require: false

# Access Google sheets programmatically
gem 'google-api-client'

# Allows periodic background jobs
gem 'sidekiq-cron'

# For making sortable searchable tables
gem 'jquery-datatables'

# Fuzzy Match
gem 'fuzzy_match'

# Allows us to authenticate via Google's servers, so we can create google exports
gem 'omniauth-google-oauth2'

gem 'googleauth'

# Allows users to drop files to upload
gem 'dropzonejs-rails'

# for things like cloning questions (extraction forms maybe?)
gem 'amoeba'

# full-stack error tracking system
gem 'sentry-ruby'
gem 'sentry-sidekiq'

# observability platform
# gem 'newrelic_rpm'
# gem 'newrelic-infinite_tracing'

# Limit request rates
gem 'rack-attack'

gem 'foreman'

gem 'ahoy_matey'

# Easy maintenance mode.
gem 'turnout'

gem 'net-smtp', require: false
gem 'tailwindcss-rails', '~> 2.0'
