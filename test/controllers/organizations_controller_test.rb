require 'test_helper'

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "should be redirected if not logged in" do
    get organizations_url
    assert_response :redirect
  end

  test "should respond success" do
    sign_in(users(:one))

    get organizations_url
    assert_response :success
  end
end

