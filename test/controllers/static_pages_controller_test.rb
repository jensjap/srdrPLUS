require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

  def setup
    @password = "password"
    @confirmed_user = users(:one)
    @unconfirmed_user = users(:two)
  end

  test "should get home" do
    get root_url
    assert_response :success
  end

  test "confirmed user should get help" do
    sign_in(user: @confirmed_user, password: @password)
    get help_url
    assert_response :success
  end

  test "confirmed user should get about" do
    sign_in(user: @confirmed_user, password: @password)
    get about_url
    assert_response :success
  end

  test "unconfirmed user should redirect to login" do
      sign_in(user: @unconfirmed_user, password: @password)
    get help_url
    assert_redirected_to new_user_session_url
  end
end
