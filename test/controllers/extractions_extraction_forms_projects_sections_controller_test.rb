require 'test_helper'
require 'minitest/byebug' if ENV['DEBUG']

class ExtractionsExtractionFormsProjectsSectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @extractions_extraction_forms_projects_section = extractions_extraction_forms_projects_sections(:three)
  end

  #test 'should create rssm' do
  #  assert_difference 'ResultStatisticSectionsMeasure.count', 2 do
  #    patch extractions_extraction_forms_projects_section_url(@extractions_extraction_forms_projects_section),
  #      params: { extractions_extraction_forms_projects_section: { type1s_attributes: { '1': { name: 'outcome 1', description: '' } }, id: @extractions_extraction_forms_projects_section.id } }
  #  end
  #end
end
