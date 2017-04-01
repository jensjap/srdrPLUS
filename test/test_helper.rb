ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'seed_data_helper'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  setup do
    extend SeedData
  end

  # Add more helper methods to be used by all tests here...
  def sign_in(user:, password:)
    post user_session_path \
      "user[email]"    => user.email,
      "user[password]" => password
  end
end
