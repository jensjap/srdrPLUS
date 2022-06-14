source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 7.0.3'
gem 'mysql2' # Use mysql as the database for Active Record
gem 'puma' # Use Puma as the app server
gem 'sass-rails', '~> 5.0' # Use SCSS for stylesheets
gem 'uglifier', '>= 1.3.0' # Use Uglifier as compressor for JavaScript assets
gem 'coffee-rails', '~> 4.2' # Use CoffeeScript for .coffee assets and views
gem 'jquery-rails' # Use jquery as the JavaScript library
gem 'jbuilder', '~> 2.10.1'
gem 'redis'
gem 'bcrypt', '~> 3.1.7'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby] # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'autoprefixer-rails' # Use Zurb Foundation as Front-End Framework
gem 'foundation-icons-sass-rails' # Use Zurb Foundation as Front-End Framework
gem 'foundation-rails' # Use Zurb Foundation as Front-End Framework
gem 'slim-rails'
gem 'cocoon'
gem 'country_select'
gem 'simple_form'
gem 'devise'
gem 'omniauth'
gem 'remotipart', github: 'mshibuya/remotipart'
gem 'toastr_rails'
gem 'paranoia', '~>2.2'
gem 'faker', github: 'stympy/faker'
gem 'gon' # Access ruby data in JavaScript.
gem 'kaminari' # Pagination.
gem 'rack-cors' # CORS.
gem 'responders' # Help DRY up code.
gem 'apipie-rails' # Api documentation.
gem 'sidekiq' # Background jobs.
gem 'caxlsx' # Spreadsheet generation.
gem 'caxlsx_rails' # Spreadsheet generation.
gem 'rubyXL', '~> 1.2.10' # Spreadsheet reading.
gem 'zip-zip' # Spreadsheet reading.
gem 'elasticsearch', '< 7.14'
gem 'searchkick'
gem 'searchjoy'
gem 'passenger'
gem 'bio' # bioruby for pubmed queries.
gem 'ref_parsers', '~> 0.2.0' # for parsing ris files.
gem 'breadcrumbs_on_rails' # breadcrumbs.
gem 'pundit' # authorizations.
gem 'sortable-rails' # List reordering, Drag & Drop.
gem 'httparty' # Simple calls to external API.
gem 'bootsnap' # New for Rails 5.2.
gem 'aws-sdk-s3', require: false # Access to AWS S3 Cloud Storage.
gem 'google-api-client' # Access Google sheets programmatically
gem 'sidekiq-cron' # Allows periodic background jobs
gem 'jquery-datatables' # For making sortable searchable tables
gem 'fuzzy_match' # Fuzzy Match
gem 'omniauth-google-oauth2'
gem 'googleauth'
gem 'dropzonejs-rails' # Allows users to drop files to upload
gem 'amoeba' # for things like cloning questions (extraction forms maybe?)
gem 'sentry-ruby' # full-stack error tracking system
gem 'sentry-sidekiq' # full-stack error tracking system
gem 'rack-attack' # Limit request rates
gem 'foreman'
gem 'ahoy_matey'
gem 'net-smtp', require: false
gem 'tailwindcss-rails', '~> 2.0'
gem 'turnout' # Easy maintenance mode

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
  gem 'annotate'
  gem 'awesome_print'
  gem 'active_record_doctor'
end
