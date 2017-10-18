require 'test_helper'

class ExtractionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @extraction = extractions(:one)
  end

  test "should get index" do
    get extractions_url
    assert_response :success
  end

  test "should get new" do
    get new_extraction_url
    assert_response :success
  end

  test "should create extraction" do
    assert_difference('Extraction.count') do
      post extractions_url, params: { extraction: { deleted_at: @extraction.deleted_at, extraction_forms_project_id: @extraction.extraction_forms_project_id, projects_study_id: @extraction.projects_study_id, projects_users_role_id: @extraction.projects_users_role_id } }
    end

    assert_redirected_to extraction_url(Extraction.last)
  end

  test "should show extraction" do
    get extraction_url(@extraction)
    assert_response :success
  end

  test "should get edit" do
    get edit_extraction_url(@extraction)
    assert_response :success
  end

  test "should update extraction" do
    patch extraction_url(@extraction), params: { extraction: { deleted_at: @extraction.deleted_at, extraction_forms_project_id: @extraction.extraction_forms_project_id, projects_study_id: @extraction.projects_study_id, projects_users_role_id: @extraction.projects_users_role_id } }
    assert_redirected_to extraction_url(@extraction)
  end

  test "should destroy extraction" do
    assert_difference('Extraction.count', -1) do
      delete extraction_url(@extraction)
    end

    assert_redirected_to extractions_url
  end
end
