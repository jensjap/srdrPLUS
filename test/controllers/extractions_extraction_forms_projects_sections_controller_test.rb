require 'test_helper'

class ExtractionsExtractionFormsProjectsSectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @extractions_extraction_forms_projects_section = extractions_extraction_forms_projects_sections(:three)
  end

  test 'this' do
    assert_difference 'ResultStatisticSectionsMeasure.count', 2 do
      patch extractions_extraction_forms_projects_section_url(@extractions_extraction_forms_projects_section),
        params: { extractions_extraction_forms_projects_section: { extractions_extraction_forms_projects_sections_type1s_attributes: { '0': { type1_attributes: { name: 'outcome 1', description: '' } } } }, id: @extractions_extraction_forms_projects_section.id }
    end
  end
end
