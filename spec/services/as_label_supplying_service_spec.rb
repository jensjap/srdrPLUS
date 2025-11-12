require 'rails_helper'

RSpec.describe AsLabelSupplyingService, type: :service do
  let(:service) { AsLabelSupplyingService.new }
  let(:user) { create(:user) }
  let(:project) { create(:project) }

  before do
    User.current = user
  end

  after do
    User.current = nil
  end

  describe '#find_by_project_id' do
    # This service returns FHIR List of arms/outcomes/etc from a project
    # For a basic project without extractions, it returns an empty list
    it 'should return FHIR List structure' do
      fhir_list = service.find_by_project_id(project.id)

      expect(fhir_list).to be_a(Hash)
      expect(fhir_list).to have_key('entry')
      expect(fhir_list['entry']).to be_a(Array)
    end
  end
end
