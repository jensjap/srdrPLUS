require 'test_helper'

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  test "should be redirected if not logged in" do
    get organizations_url
    assert_response :redirect
  end

  test "should respond success" do
    sign_in(users(:one))

    get organizations_url, as: :json
    assert_response :success
    assert_equal 'application/json; charset=utf-8', @response.content_type

    # Parse the response body as JSON and assert the expected values
    json_response = JSON.parse(@response.body)
    assert_equal 'Success', json_response['message']
  end
end
