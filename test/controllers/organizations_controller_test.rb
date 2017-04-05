require 'test_helper'

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get organizations_index_url
    assert_response :success
  end

end
