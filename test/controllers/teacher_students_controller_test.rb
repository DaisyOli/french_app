require "test_helper"

class TeacherStudentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @teacher_a = users(:one)
    @teacher_b = users(:two)
    @student = students(:one)
    @student.update!(invited_by: @teacher_a)
  end

  test "teacher sees their own students in the index" do
    sign_in @teacher_a
    get teacher_students_path
    assert_response :success
    assert_match @student.email, response.body
  end

  # Achado repetido nesta sessão: sempre confirmar que "não aparece na
  # lista" também significa "não abre por URL direta" (não só esconder na UI).
  test "teacher does not see another teacher's students in the index" do
    sign_in @teacher_b
    get teacher_students_path
    assert_response :success
    assert_no_match @student.email, response.body
  end

  test "teacher can view their own student's profile" do
    sign_in @teacher_a
    get teacher_student_path(@student)
    assert_response :success
  end

  test "teacher cannot view another teacher's student profile by direct URL" do
    sign_in @teacher_b
    get teacher_student_path(@student)
    assert_response :not_found
  end

  test "teacher can update their own student's level" do
    sign_in @teacher_a
    patch update_level_teacher_student_path(@student), params: { student: { "nível" => "B1" } }
    @student.reload
    assert_equal "B1", @student.nível
  end

  test "teacher cannot update another teacher's student level" do
    sign_in @teacher_b
    patch update_level_teacher_student_path(@student), params: { student: { "nível" => "B1" } }
    assert_response :not_found
    assert_nil @student.reload.nível
  end

  test "teacher can remove their own student" do
    sign_in @teacher_a
    delete remove_teacher_student_path(@student)
    assert_redirected_to teacher_students_path
    assert_nil @student.reload.invited_by_id
  end

  test "teacher cannot remove another teacher's student" do
    sign_in @teacher_b
    delete remove_teacher_student_path(@student)
    assert_response :not_found
    assert_equal @teacher_a.id, @student.reload.invited_by_id
  end

  test "teacher cannot view another teacher's student attestation" do
    sign_in @teacher_b
    get attestation_teacher_student_path(@student)
    assert_response :not_found
  end

  # Sprint 8-FR: o atestado só soma atividades que o PRÓPRIO professor
  # autor criou — é quem assina o documento.
  test "attestation only counts activities authored by the requesting teacher" do
    own_activity = activities(:one)
    own_activity.update!(user: @teacher_a)
    other_activity = activities(:two)
    other_activity.update!(user: @teacher_b)

    CompletedActivity.create!(student: @student, activity: own_activity, score: 8, total_questions: 10,
                               started_at: 30.minutes.ago, completed_at: Time.current)
    CompletedActivity.create!(student: @student, activity: other_activity, score: 9, total_questions: 10,
                               started_at: 20.minutes.ago, completed_at: Time.current)

    sign_in @teacher_a
    get attestation_teacher_student_path(@student)
    assert_response :success
    assert_match own_activity.título, response.body
    assert_no_match other_activity.título, response.body
  end
end
