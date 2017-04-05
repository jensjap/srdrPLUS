require 'test_helper'

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "should be redirected if not logged in" do
    get organizations_url
    assert_response :redirect
  end
end

