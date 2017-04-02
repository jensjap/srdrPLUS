require 'test_helper'

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @password = "password"
    @confirmed_user = users(:one)
    @unconfirmed_user = users(:two)
  end

  test "confirmed user should get edit" do
    sign_in(@confirmed_user)
    get edit_user_registration_url
    assert_response :success
  end

  test "unconfirmed user should redirect to login" do
    # For a unconfirmed user Warden throws an error if we try
    # to use Devise::Test::IntegrationHelpers#sign_in.
    # So we use our own #sign_in_as defined in test/test_helper.rb
    sign_in_as(user: @unconfirmed_user, password: @password)
    get edit_user_registration_url
    assert_redirected_to new_user_session_url
  end
end

