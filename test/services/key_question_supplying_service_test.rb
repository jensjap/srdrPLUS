require 'test_helper'

class KeyQuestionSupplyingServiceTest < ActiveSupport::TestCase
  setup do
    @service = KeyQuestionSupplyingService.new
    @project = projects(:one)
    @key_question = key_questions_projects(:one)
  end

  test "should return FHIR Bundle of key questions" do
    bundle = @service.find_by_project_id(@project.id)

    assert_not_empty bundle.entry
  end

  test "should return FHIR EvidenceVariable of key question" do
    key_question = @service.find_by_key_question_id(@key_question.id)

    assert_equal @key_question.id, key_question.id.split('-').last.to_i
  end
end
