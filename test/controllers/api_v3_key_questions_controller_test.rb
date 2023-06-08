require 'test_helper'

class KeyQuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @project = projects(:one)
    @key_question = key_questions(:one)
  end

  test 'should get index' do
    get api_v3_project_key_questions_url(@project), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @project.key_questions.count, json_response['entry'].count
  end

  test 'should show key question' do
    get api_v3_key_question_url(@key_question), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @key_question.id, json_response['id'].split('-').last.to_i
  end
end
