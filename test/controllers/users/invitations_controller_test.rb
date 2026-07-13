require "test_helper"

class Users::InvitationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @admin = users(:one)
    @admin.update!(admin: true)
    @regular_teacher = users(:two)
  end

  test "admin can access the new teacher invitation form" do
    sign_in @admin
    get new_user_invitation_path
    assert_response :success
  end

  test "admin can invite a new teacher" do
    sign_in @admin
    assert_difference("User.count") do
      post user_invitation_path, params: { user: { email: "novo.professeur@example.com" } }
    end
  end

  # Sprint 5-FR: só admin convida professor — igual ao practice-br. Um
  # professor comum não pode nem ver o formulário nem criar o convite.
  test "regular teacher is blocked from the new teacher invitation form" do
    sign_in @regular_teacher
    get new_user_invitation_path
    assert_redirected_to teacher_dashboard_path
  end

  test "regular teacher cannot invite a new teacher" do
    sign_in @regular_teacher
    assert_no_difference("User.count") do
      post user_invitation_path, params: { user: { email: "novo.professeur@example.com" } }
    end
  end

  test "guest is blocked from inviting a teacher" do
    assert_no_difference("User.count") do
      post user_invitation_path, params: { user: { email: "novo.professeur@example.com" } }
    end
  end
end
