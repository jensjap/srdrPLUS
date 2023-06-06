require 'test_helper'

class CitationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @project = projects(:one)
    @citation = citations(:one)
  end

  test 'should get index' do
    get api_v3_project_citations_url(@project), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @project.citations.count, json_response.length
  end

  test 'should show citation' do
    get api_v3_citation_url(@citation), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @citation.id, json_response['id']
  end
end
