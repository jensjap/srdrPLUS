require 'test_helper'

class Api::V3::ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @project = projects(:one)
  end

  test 'should get project in JSON format' do
    get api_v3_project_url(@project, format: :json)
    assert_response :success
    assert_equal 'application/json', @response.media_type
  end

  test 'should get project in XML format' do
    get api_v3_project_url(@project, format: :xml)
    assert_response :success
    assert_equal 'application/xml', @response.media_type
  end
end
