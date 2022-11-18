source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

group :development, :test do
  gem 'byebug'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'simplecov', require: false
end

group :development do
  gem 'active_record_doctor'
  gem 'annotate'
  gem 'bullet'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'ahoy_matey'
gem 'amoeba' # for things like cloning questions (extraction forms maybe?)
gem 'apipie-rails' # Api documentation.
gem 'autoprefixer-rails' # Use Zurb Foundation as Front-End Framework
gem 'awesome_print'
gem 'aws-sdk-s3', require: false # Access to AWS S3 Cloud Storage.
gem 'bcrypt', '~> 3.1.7'
gem 'bio' # bioruby for pubmed queries.
gem 'bootsnap' # New for Rails 5.2.
gem 'caxlsx' # Spreadsheet generation.
gem 'caxlsx_rails' # Spreadsheet generation.
gem 'cocoon'
gem 'coffee-rails', '~> 4.2' # Use CoffeeScript for .coffee assets and views
gem 'country_select'
gem 'devise'
gem 'dotenv-rails'
gem 'dropzonejs-rails' # Allows users to drop files to upload
gem 'elasticsearch', '< 7.14'
gem 'faker', github: 'faker-ruby/faker', branch: 'main'
gem 'fhir_models', github: 'sleepwalk712/fhir_models'
gem 'font-awesome-rails'
gem 'foreman'
gem 'foundation-icons-sass-rails' # Use Zurb Foundation as Front-End Framework
gem 'foundation-rails' # Use Zurb Foundation as Front-End Framework
gem 'fuzzy_match' # Fuzzy Match
gem 'gon' # Access ruby data in JavaScript.
gem 'google-api-client' # Access Google sheets programmatically
gem 'googleauth'
gem 'httparty' # Simple calls to external API.
gem 'jbuilder', '~> 2.10.1'
gem 'jquery-datatables' # For making sortable searchable tables
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'kaminari' # Pagination.
gem 'mysql2' # Use mysql as the database for Active Record
gem 'net-ftp'
gem 'net-smtp', require: false
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'paranoia', '~>2.2'
gem 'passenger'
gem 'puma' # Use Puma as the app server
gem 'pundit' # authorizations.
gem 'rack-attack' # Limit request rates
gem 'rack-cors' # CORS.
gem 'rails', '~> 7.0.3'
gem 'redis', '4.7.1'
gem 'ref_parsers', '~> 0.2.0' # for parsing ris files.
gem 'remotipart', github: 'mshibuya/remotipart'
gem 'responders' # Help DRY up code.
gem 'roo', '~> 2.9.0'
gem 'rubyXL', '3.4.25' # Spreadsheet reading.
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'searchjoy'
gem 'searchkick'
gem 'sentry-rails'
gem 'sentry-ruby' # full-stack error tracking system
gem 'sentry-sidekiq' # full-stack error tracking system
gem 'sidekiq', '<7' # Background jobs.
gem 'sidekiq-cron' # Allows periodic background jobs
gem 'simple_form'
gem 'slim-rails'
gem 'sortable-rails' # List reordering, Drag & Drop.
gem 'tailwindcss-rails', '~> 2.0'
gem 'toastr_rails'
gem 'turnout' # Easy maintenance mode
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby] # Windows does not include zoneinfo files
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'zip-zip' # Spreadsheet reading.
