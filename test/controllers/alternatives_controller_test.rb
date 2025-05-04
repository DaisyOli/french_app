require "test_helper"

class AlternativesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get alternatives_new_url
    assert_response :success
  end

  test "should get create" do
    get alternatives_create_url
    assert_response :success
  end

  test "should get edit" do
    get alternatives_edit_url
    assert_response :success
  end

  test "should get update" do
    get alternatives_update_url
    assert_response :success
  end

  test "should get destroy" do
    get alternatives_destroy_url
    assert_response :success
  end
end
