require "test_helper"

class StudentsInvitationMailerTest < ActionMailer::TestCase
  test "invitation email shows the inviting teacher's name when present" do
    teacher = users(:one)
    teacher.update!(name: "Daisy")
    student = Student.new(email: "convidada@example.com", invited_by: teacher)

    mail = Devise::Mailer.invitation_instructions(student, "abc123")

    html = mail.html_part.body.to_s
    assert_includes html, "Daisy"
  end

  # Sprint do e-mail (2026-07-13): antes de ter mais professores, o nome
  # pode estar em branco — o e-mail não deve quebrar nem mostrar "convidado
  # por " vazio, só cai num texto genérico.
  test "invitation email falls back to generic text when the teacher has no name" do
    teacher = users(:two)
    teacher.update!(name: nil)
    student = Student.new(email: "convidada2@example.com", invited_by: teacher)

    mail = Devise::Mailer.invitation_instructions(student, "abc123")

    html = mail.html_part.body.to_s
    assert_includes html, "Vous avez été invité"
  end
end
