require 'test_helper'

class ExtractionFormsProjectsSectionSupplyingServiceTest < ActiveSupport::TestCase
  setup do
    @service = ExtractionFormsProjectsSectionSupplyingService.new
    @efp = extraction_forms_projects(:one)
    @efps = extraction_forms_projects_sections(:one)
  end

  test "should return FHIR Bundle of efps" do
    bundle = @service.find_by_extraction_forms_project_id(@efp.id)

    assert_instance_of FHIR::Bundle, bundle
    assert_not_empty bundle.entry
    assert bundle.entry.first.resource.is_a?(FHIR::Questionnaire)
  end

  test "should return FHIR Questionnaire Resource of efps" do
    efps = @service.find_by_extraction_forms_projects_section_id(@efps.id)

    assert_instance_of FHIR::Questionnaire, efps
    assert_equal @efps.id, efps.id.split('-').last.to_i
  end
end
