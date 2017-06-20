require 'test_helper'

class KeyQuestionsProjectTest < ActiveSupport::TestCase
  def setup
    @key_questions_project_one   = key_questions_projects(:one)
    @key_questions_project_two   = key_questions_projects(:one)
    @extraction_forms_projects_section_type_one   = extraction_forms_projects_sections(:one)
    @extraction_forms_projects_section_type_two   = extraction_forms_projects_sections(:two)
    @extraction_forms_projects_section_type_three = extraction_forms_projects_sections(:three)
    @extraction_forms_projects_section_type_four  = extraction_forms_projects_sections(:four)
  end

  test 'KeyQuestionsProject should only associate with ExtractionFormsProjectsSectionType of type 4 (Key Questions)' do
    assert @key_questions_project_one.valid?
    @key_questions_project_one.extraction_forms_projects_section = @extraction_forms_projects_section_type_one
    assert_not @key_questions_project_one.valid?
  end
end
