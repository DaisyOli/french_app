require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email: "professeur@example.com", password: "password123")
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "should require unique email" do
    @user.save!
    duplicate = User.new(email: @user.email, password: "password123")
    assert_not duplicate.valid?
  end

  test "admin? should default to false" do
    @user.save!
    assert_not @user.admin?
  end

  # Sprint 4-FR: só existe promoção a admin via console (bin/rails runner),
  # de propósito — não existe fluxo de auto-promoção nem UI pra isso.
  test "admin? should be true when the admin column is set" do
    @user.admin = true
    @user.save!
    assert @user.admin?
  end

  test "should not allow self-registration (registerable removido de propósito)" do
    # Achado da faxina de 2026-07-13: User tinha :registerable ligado desde
    # antes do fluxo de convite existir, o que permitia qualquer um criar
    # conta de professor direto em /users/sign_up, sem convite nem admin.
    assert_not User.devise_modules.include?(:registerable)
  end

  # Sprint do painel admin: apagar um professor não pode apagar os alunos
  # dele junto — só desvincula (mesma convenção do "remover aluno" que o
  # próprio professor já tinha).
  test "destroying a teacher unlinks (does not destroy) their students" do
    @user.save!
    student = Student.create!(email: "aluno.unlink@example.com", password: "password123", invited_by: @user)

    @user.destroy

    assert Student.exists?(student.id)
    student.reload
    assert_nil student.invited_by_id
    assert_nil student.invited_by_type
  end

  test "destroying a teacher destroys their activities" do
    @user.save!
    activity = Activity.create!(título: "Activité à supprimer", nível: "A1", user: @user)

    @user.destroy

    assert_not Activity.exists?(activity.id)
  end
end
