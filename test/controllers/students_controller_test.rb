require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @student = students(:one)
    @a1_activity = activities(:one) # nível A1
    @c2_activity = activities(:two) # nível C2 (fixture "two")
    @c2_activity.update!(nível: "C2")
  end

  test "student without a nível sees activities from every level" do
    @student.update!(nível: nil)
    sign_in @student
    get student_activities_path
    assert_response :success
    assert_match @a1_activity.título, response.body
    assert_match @c2_activity.título, response.body
  end

  # Sprint 6-FR: nível restringe acesso (decisão explícita da Daisy) — um
  # aluno A1 não deve ver nem a lista de atividades C2.
  test "student with a nível only sees activities within their accessible levels" do
    @student.update!(nível: "A1")
    sign_in @student
    get student_activities_path
    assert_response :success
    assert_match @a1_activity.título, response.body
    assert_no_match @c2_activity.título, response.body
  end

  test "dashboard marks levels above the student's own as locked" do
    @student.update!(nível: "A1")
    sign_in @student
    get student_dashboard_path
    assert_response :success
  end
end
