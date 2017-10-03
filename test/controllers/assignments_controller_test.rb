require 'test_helper'

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get assignments_new_url
    assert_response :success
  end

  test "should get create" do
    get assignments_create_url
    assert_response :success
  end

  test "should get edit" do
    get assignments_edit_url
    assert_response :success
  end

  test "should get update" do
    get assignments_update_url
    assert_response :success
  end

  test "should get destroy" do
    get assignments_destroy_url
    assert_response :success
  end

  test "should get index" do
    get assignments_index_url
    assert_response :success
  end

  test "should get show" do
    get assignments_show_url
    assert_response :success
  end

end
