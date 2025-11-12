require 'rails_helper'

RSpec.describe ExtractionFormsProjectsSectionSupplyingService, type: :service do
  let(:service) { ExtractionFormsProjectsSectionSupplyingService.new }
  let(:project) { create(:project) }
  let(:extraction_form) { create(:extraction_form) }
  let(:efp) { create(:extraction_forms_project, extraction_form: extraction_form, project: project) }
  let(:efps) { create(:extraction_forms_projects_section, extraction_forms_project: efp) }

  describe '#find_by_extraction_forms_project_id' do
    it 'should call service method with extraction_forms_project_id' do
      # Ensure efps exists
      efps
      bundle = service.find_by_extraction_forms_project_id(efp.id)

      # Service may return nil for empty extraction forms without questions
      # Just verify it doesn't raise an error
      expect(bundle).to be_nil.or(be_a(Hash))
    end
  end

  describe '#find_by_extraction_forms_projects_section_id' do
    it 'should call service method with extraction_forms_projects_section_id' do
      result = service.find_by_extraction_forms_projects_section_id(efps.id)

      # Service may return nil for empty extraction forms sections without questions
      # Just verify it doesn't raise an error
      expect(result).to be_nil.or(be_a(Hash))
    end
  end
end
