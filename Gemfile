source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.0'

# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.18', '< 0.5'
# Use Puma as the app server
gem 'puma', '~> 3.12'
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
gem 'jquery-turbolinks'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem "rspec_junit_formatter"
  gem 'dotenv-rails'
end

group :test do
  gem 'minitest-rails-capybara'
  gem 'simplecov', require: false
  gem 'database_cleaner-active_record'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', github: 'rails/web-console'
  gem 'guard'
  gem 'guard-minitest'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Annotate Models
  gem 'annotate', '~> 2.7', '>= 2.7.4'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]


## Non-default gems.

# Use Zurb Foundation as Front-End Framework
gem 'foundation-rails'
gem 'autoprefixer-rails'
gem 'foundation-icons-sass-rails'

# Prettier templates.
gem 'slim-rails'

# Simplified forms.
gem 'simple_form'
gem 'country_select'
gem 'cocoon'

# Authentication.
gem 'devise'
gem 'omniauth'
gem 'remotipart', github: 'mshibuya/remotipart'
gem 'rails_admin', '~> 1.3.0'

# Flash messages.
gem 'toastr_rails'

# Versioning of models + soft-delete.
gem 'paper_trail'
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
gem 'axlsx', git: 'https://github.com/randym/axlsx.git'
gem 'axlsx_rails'

# Spreadsheet reading.
gem 'rubyXL'

# Searching with Elasticsearch.
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
gem 'sidekiq-cron', '~> 1.1'

# For making sortable searchable tables
gem 'jquery-datatables'

# Formatted console logs
gem 'awesome_print'

# Fuzzy Match
gem 'fuzzy_match'

# Font Awesome Icons
#gem 'font-awesome-rails'

# Allows us to authenticate via Google's servers, so we can create google exports
gem "omniauth-google-oauth2"

gem "googleauth"

# Allows users to drop files to upload
gem "dropzonejs-rails"

# for things like cloning questions (extraction forms maybe?)
gem "amoeba"

# full-stack error tracking system
gem "sentry-raven"