require 'rails_helper'

RSpec.describe KeyQuestionSupplyingService, type: :service do
  let(:service) { KeyQuestionSupplyingService.new }
  let(:project) { create(:project) }
  let(:key_questions_project) { create(:key_questions_project, project: project) }

  before(:each) do
    # Set User.current to a valid user to handle after_create callbacks
    User.current = create(:user)
  end

  after(:each) do
    User.current = nil
  end

  describe '#find_by_project_id' do
    it 'should return FHIR Bundle of key questions' do
      # Ensure key_questions_project exists
      key_questions_project
      bundle = service.find_by_project_id(project.id)

      expect(bundle['entry']).not_to be_empty
    end
  end

  describe '#find_by_key_question_id' do
    it 'should return FHIR EvidenceVariable of key question' do
      result = service.find_by_key_question_id(key_questions_project.id)

      expect(result['id'].split('-').last.to_i).to eq(key_questions_project.id)
    end
  end
end
