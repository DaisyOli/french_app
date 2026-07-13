require "test_helper"

class Admin::StudentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @admin = users(:one)
    @admin.update!(admin: true)
    @regular_teacher = users(:two)
  end

  test "admin can delete a student" do
    sign_in @admin
    assert_difference("Student.count", -1) do
      delete admin_student_path(students(:one))
    end
    assert_redirected_to admin_root_path
  end

  test "deleting a student logs an admin action" do
    sign_in @admin
    student = students(:one)
    assert_difference("AdminAuditLog.count") do
      delete admin_student_path(student)
    end
    assert_equal "delete_student", AdminAuditLog.last.action
    assert_equal student.email, AdminAuditLog.last.target_description
  end

  test "regular teacher is blocked from deleting a student" do
    sign_in @regular_teacher
    assert_no_difference("Student.count") do
      delete admin_student_path(students(:one))
    end
    assert_redirected_to teacher_dashboard_path
  end

  test "guest is redirected to login" do
    assert_no_difference("Student.count") do
      delete admin_student_path(students(:one))
    end
    assert_redirected_to new_user_session_path
  end
end
