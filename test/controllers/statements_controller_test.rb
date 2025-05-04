require "test_helper"

class StatementsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get statements_new_url
    assert_response :success
  end

  test "should get create" do
    get statements_create_url
    assert_response :success
  end

  test "should get edit" do
    get statements_edit_url
    assert_response :success
  end

  test "should get update" do
    get statements_update_url
    assert_response :success
  end

  test "should get destroy" do
    get statements_destroy_url
    assert_response :success
  end
end
