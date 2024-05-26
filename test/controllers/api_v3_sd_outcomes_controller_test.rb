require 'test_helper'

class SdOutcomesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @sd_outcome = sd_outcomes(:one)
  end

  test 'should show sd outcome' do
    get api_v3_sd_outcome_url(@sd_outcome), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @sd_outcome.id, json_response['id'].split('-').last.to_i
  end
end
