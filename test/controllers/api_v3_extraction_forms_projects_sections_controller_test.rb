require 'test_helper'

class ExtractionFormsProjectsSectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @efp = extraction_forms_projects(:one)
    @efps = extraction_forms_projects_sections(:one)
  end

  test 'should get index' do
    get api_v3_extraction_forms_project_extraction_forms_projects_sections_url(@efp), as: :json
    assert_response :success
  end

  test 'should show efps' do
    get api_v3_extraction_forms_projects_section_url(@efps), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @efps.id, json_response['id'].split('-').last.to_i
  end
end
