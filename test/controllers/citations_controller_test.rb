require 'test_helper'

class CitationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get citations_new_url
    assert_response :success
  end

  test "should get create" do
    get citations_create_url
    assert_response :success
  end

  test "should get update" do
    get citations_update_url
    assert_response :success
  end

  test "should get edit" do
    get citations_edit_url
    assert_response :success
  end

  test "should get delete" do
    get citations_delete_url
    assert_response :success
  end

end
