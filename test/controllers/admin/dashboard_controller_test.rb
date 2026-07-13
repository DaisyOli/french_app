require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @admin = users(:one)
    @admin.update!(admin: true)
    @regular_teacher = users(:two)
  end

  test "admin can access the dashboard" do
    sign_in @admin
    get admin_root_path
    assert_response :success
  end

  test "regular teacher is blocked from the admin dashboard" do
    sign_in @regular_teacher
    get admin_root_path
    assert_redirected_to teacher_dashboard_path
  end

  test "guest is redirected to login" do
    get admin_root_path
    assert_redirected_to new_user_session_path
  end

  test "dashboard shows platform-wide teacher and student counts" do
    sign_in @admin
    get admin_root_path
    assert_response :success
    assert_match users(:two).email, response.body
    assert_match students(:one).email, response.body
  end
end
