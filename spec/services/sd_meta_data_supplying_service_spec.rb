require 'rails_helper'

RSpec.describe SdMetaDataSupplyingService, type: :service do
  let(:service) { SdMetaDataSupplyingService.new }
  let(:project) { create(:project) }
  let(:sd_meta_datum) { create(:sd_meta_datum, project: project) }

  describe '#find_by_project_id' do
    it 'should return FHIR Bundle of sd_meta_datum' do
      # Ensure sd_meta_datum exists
      sd_meta_datum
      bundle = service.find_by_project_id(project.id)

      expect(bundle['entry']).not_to be_empty
    end
  end

  describe '#find_by_sd_meta_data_id' do
    it 'should return FHIR Bundle of sd_meta_data' do
      bundle = service.find_by_sd_meta_data_id(sd_meta_datum.id)

      expect(bundle['entry']).not_to be_empty
    end
  end
end
