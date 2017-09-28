require 'test_helper'

class JournalControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get journal_new_url
    assert_response :success
  end

  test "should get create" do
    get journal_create_url
    assert_response :success
  end

  test "should get edit" do
    get journal_edit_url
    assert_response :success
  end

  test "should get update" do
    get journal_update_url
    assert_response :success
  end

  test "should get show" do
    get journal_show_url
    assert_response :success
  end

  test "should get index" do
    get journal_index_url
    assert_response :success
  end

  test "should get destroy" do
    get journal_destroy_url
    assert_response :success
  end

end
