require 'test_helper'

class ExtractionFormsProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
  end

  test "should get edit" do
    get edit_extraction_forms_project_url(ExtractionFormsProject.first)
    assert_response :success
  end

end
