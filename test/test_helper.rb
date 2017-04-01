ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails/capybara'
require 'seed_data_helper'

class ActiveSupport::TestCase
  # Makes available #sign_in and #sign_out
  include Devise::Test::IntegrationHelpers

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  setup do
    extend SeedData
  end

  # Add more helper methods to be used by all tests here...
  def sign_in_as(user:, password:)
    post user_session_path \
      "user[email]"    => user.email,
      "user[password]" => password
  end
end
