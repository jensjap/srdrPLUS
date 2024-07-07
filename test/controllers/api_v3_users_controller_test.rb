require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @user = users(:one)
  end

  test 'should show user' do
    get api_v3_user_url(@user), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @user.id, json_response['id'].split('-').last.to_i
  end
end
