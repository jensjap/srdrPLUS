require 'test_helper'

class SdSearchStrategiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @sd_search_strategy = sd_search_strategies(:one)
  end

  test 'should show sd search strategy' do
    get api_v3_sd_search_strategy_url(@sd_search_strategy), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @sd_search_strategy.id, json_response['id'].split('-').last.to_i
  end
end
