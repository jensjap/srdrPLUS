require 'rails_helper'

RSpec.describe AllResourceSupplyingService, type: :service do
  let(:project) { create(:project) }
  let(:service) { AllResourceSupplyingService.new }

  describe '#document_find_by_project_id' do
    it 'should get project info in Bundle format' do
      result = service.document_find_by_project_id(project.id)

      expect(result['entry']).to be_present
      expect(result['resourceType']).to eq('Bundle')
    end
  end
end
