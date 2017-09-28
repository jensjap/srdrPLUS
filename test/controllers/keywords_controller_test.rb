require 'test_helper'

class KeywordsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get keywords_new_url
    assert_response :success
  end

  test "should get create" do
    get keywords_create_url
    assert_response :success
  end

  test "should get destroy" do
    get keywords_destroy_url
    assert_response :success
  end

  test "should get edit" do
    get keywords_edit_url
    assert_response :success
  end

  test "should get update" do
    get keywords_update_url
    assert_response :success
  end

  test "should get show" do
    get keywords_show_url
    assert_response :success
  end

  test "should get index" do
    get keywords_index_url
    assert_response :success
  end

end
