Rails.application.config.active_storage.service_urls_expire_in = 24.hour
Rails.application.reloader.to_prepare do
  ActiveStorage::Blob
end
