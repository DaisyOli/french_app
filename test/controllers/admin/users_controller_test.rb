require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @admin = users(:one)
    @admin.update!(admin: true)
    @regular_teacher = users(:two)
  end

  test "admin can update a teacher's name" do
    sign_in @admin
    patch admin_user_path(@regular_teacher), params: { user: { name: "Jean Dupont" } }
    assert_redirected_to admin_root_path
    assert_equal "Jean Dupont", @regular_teacher.reload.name
  end

  test "updating a teacher's name logs an admin action" do
    sign_in @admin
    assert_difference("AdminAuditLog.count") do
      patch admin_user_path(@regular_teacher), params: { user: { name: "Jean Dupont" } }
    end
    assert_equal "update_teacher_name", AdminAuditLog.last.action
    assert_equal @regular_teacher.email, AdminAuditLog.last.target_description
  end

  test "admin can delete another teacher" do
    sign_in @admin
    assert_difference("User.count", -1) do
      delete admin_user_path(@regular_teacher)
    end
    assert_redirected_to admin_root_path
  end

  test "deleting a teacher destroys their activities and unlinks their students" do
    activity = activities(:two) # belongs to users(:two) per fixtures
    student = Student.create!(email: "aluno.painel@example.com", password: "password123", invited_by: @regular_teacher)

    sign_in @admin
    delete admin_user_path(@regular_teacher)

    assert_not Activity.exists?(activity.id)
    assert Student.exists?(student.id)
    assert_nil student.reload.invited_by_id
  end

  test "deleting a teacher logs an admin action with counts" do
    sign_in @admin
    assert_difference("AdminAuditLog.count") do
      delete admin_user_path(@regular_teacher)
    end
    assert_equal "delete_teacher", AdminAuditLog.last.action
    assert_equal @regular_teacher.email, AdminAuditLog.last.target_description
  end

  test "admin cannot delete their own account" do
    sign_in @admin
    assert_no_difference("User.count") do
      delete admin_user_path(@admin)
    end
    assert_redirected_to admin_root_path
  end

  test "regular teacher is blocked from deleting a teacher" do
    sign_in @regular_teacher
    assert_no_difference("User.count") do
      delete admin_user_path(@admin)
    end
    assert_redirected_to teacher_dashboard_path
  end
end
