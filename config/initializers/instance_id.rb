require "securerandom"

id =
  if ENV["APP_INSTANCE_ID"].present?
    ENV["APP_INSTANCE_ID"]
  else
    Rails.application.class.module_parent_name.to_s.presence || "app-" + SecureRandom.uuid
  end

APP_INSTANCE_ID = id.freeze
