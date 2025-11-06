source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

group :development, :test do
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'simplecov', require: false
end

group :development do
  gem 'active_record_doctor'
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
end

group :production do
  gem 'aws-sigv4'
  gem 'faraday_middleware-aws-sigv4'
end

gem 'amoeba' # for things like cloning questions (extraction forms maybe?)
gem 'apipie-rails' # Api documentation.
gem 'autoprefixer-rails' # Use Zurb Foundation as Front-End Framework
gem 'awesome_print'
gem 'aws-sdk-s3', require: false # Access to AWS S3 Cloud Storage.
gem 'aws-sdk-secretsmanager'
gem 'base64', '0.1.1'
gem 'benchmark'
gem 'bcrypt'
gem 'bio' # bioruby for pubmed queries.
gem 'bootsnap' # New for Rails 5.2.
gem 'caxlsx' # Spreadsheet generation.
gem 'caxlsx_rails' # Spreadsheet generation.
gem 'cocoon'
gem 'coffee-rails' # Use CoffeeScript for .coffee assets and views
gem 'country_select'
gem 'devise'
gem 'dotenv-rails'
gem 'dropzonejs-rails' # Allows users to drop files to upload
gem 'faker', github: 'faker-ruby/faker', branch: 'main'
gem 'fhir_models', github: 'sleepwalk712/fhir_models'
gem 'font-awesome-rails'
gem 'foreman'
gem 'foundation-icons-sass-rails' # Use Zurb Foundation as Front-End Framework
gem 'foundation-rails' # Use Zurb Foundation as Front-End Framework
gem 'fuzzy_match' # Fuzzy Match
gem 'gon' # Access ruby data in JavaScript.
gem 'httparty' # Simple calls to external API.
gem 'irb'
gem 'jbuilder'
gem 'jquery-datatables' # For making sortable searchable tables
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'json_schemer'
gem 'kaminari' # Pagination.
gem 'logger'
gem 'mutex_m', '~> 0.2', require: false
gem 'mysql2' # Use mysql as the database for Active Record
gem 'net-ftp'
gem 'net-smtp', require: false
gem 'nokogiri'
gem 'opensearch-ruby', '~> 2.0'
gem 'ostruct'
gem 'parallel'
gem 'passenger'
gem 'puma' # Use Puma as the app server
gem 'pundit' # authorizations.
gem 'rack-attack' # Limit request rates
gem 'rack-cors' # CORS.
gem 'rails', '~> 7.0.3'
gem 'rdoc'
gem 'redis'
gem 'ref_parsers', github: 'jensjap/ref_parsers' # for parsing ris files.
gem 'remotipart', github: 'mshibuya/remotipart'
gem 'responders' # Help DRY up code.
gem 'roo'
gem 'rubyXL' # Spreadsheet reading.
gem 'sass-rails' # Use SCSS for stylesheets
gem 'searchjoy'
gem 'searchkick'
gem 'sentry-rails'
gem 'sentry-ruby' # full-stack error tracking system
gem 'sentry-sidekiq' # full-stack error tracking system
gem 'sidekiq' # Background jobs.
gem 'sidekiq-cron' # Allows periodic background jobs
gem 'simple_form'
gem 'slim-rails'
gem 'sortable-rails' # List reordering, Drag & Drop.
gem 'tailwindcss-rails'
gem 'toastr_rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby] # Windows does not include zoneinfo files
gem 'uglifier' # Use Uglifier as compressor for JavaScript assets
gem 'zip-zip' # Spreadsheet reading.
