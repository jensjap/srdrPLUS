require 'test_helper'

class SdKeyQuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @sd_key_question = sd_key_questions(:one)
  end

  test 'should show sd key question' do
    get api_v3_sd_key_question_url(@sd_key_question), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @sd_key_question.id, json_response['id'].split('-').last.to_i
  end
end
