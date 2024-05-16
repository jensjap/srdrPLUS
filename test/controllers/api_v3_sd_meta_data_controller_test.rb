require 'test_helper'

class SdMetaDataControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @project = projects(:one)
    @sd_meta_data = sd_meta_data(:one)
  end

  test 'should get index' do
    get api_v3_project_sd_meta_data_url(@project), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @project.sd_meta_data.count, json_response['entry'].count
  end

  test 'should show sd meta data' do
    get api_v3_sd_meta_datum_url(@sd_meta_data), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @sd_meta_data.id, json_response['id'].split('-').last.to_i
  end

  test 'should show composition' do
    get composition_api_v3_sd_meta_datum_url(@sd_meta_data), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 'Composition', json_response['resourceType']
  end
end
