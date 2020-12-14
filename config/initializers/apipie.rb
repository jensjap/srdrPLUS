Apipie.configure do |config|
  config.app_name                = "SRDR+"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apipie"
  config.translate               = false
  config.default_version         = "2.0"
  config.app_info["1.0"] = "
    API documentation version 1 for SRDR+.
  "
  config.app_info["2.0"] = "
    API documentation version 2 for SRDR+.
  "
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v2/**/*.rb"
end
