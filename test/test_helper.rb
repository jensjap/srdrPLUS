# frozen_string_literal: true

# Needs to be at the top.
if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  SimpleCov.start do
    add_filter '/.bundle/'  # We don't want to include bundled gems.
  end
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/rails/capybara'
require 'seed_data_helper'

# reindex models
Project.reindex

# and disable callbacks
Searchkick.disable_callbacks

class ActiveSupport::TestCase
  # Makes available #sign_in and #sign_out
  include Devise::Test::IntegrationHelpers

  # Setup all fixtures in test/fixtures/*.yml for all tests in
  # alphabetical order.
  fixtures :all

  setup do
    # Set current_user for suggestable after_create callback.
    # We do this via User.current=()
    # We need to set this because in model tests before_action in
    # ApplicationController is not called. So if model tests run before
    # controller tests, then the User.current may not be set to the
    # correct/current user.
    User.current = User.first

    extend SeedData
  end

  # Add more helper methods to be used by all tests here...
  def sign_in_as(user:, password:)
    post user_session_path \
      'user[email]'    => user.email,
      'user[password]' => password
  end
end
