require 'test_helper'

class ExtractionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @project = projects(:one)
    @extraction = extractions(:one)
  end

  test 'should get index' do
    get api_v3_project_extractions_url(@project), as: :json
    assert_response :success
  end

  test 'should show extraction' do
    get api_v3_extraction_url(@extraction), as: :json
    assert_response :success
  end
end
