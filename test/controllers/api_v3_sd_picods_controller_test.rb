require 'test_helper'

class SdPicodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @sd_picod = sd_picods(:one)
  end

  test 'should show sd picod' do
    get api_v3_sd_picod_url(@sd_picod), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @sd_picod.id, json_response['id'].split('-').last.to_i
  end
end
