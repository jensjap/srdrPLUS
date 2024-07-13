if defined?(BetterErrors) && Rails.env.development?
  # Allows access from any IP. Replace with specific IP if needed for security.
  BetterErrors::Middleware.allow_ip! "0.0.0.0/0"
end
