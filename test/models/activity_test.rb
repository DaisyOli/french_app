require "test_helper"

class ActivityTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)  # Usando fixture existente
    @activity = Activity.new(
      título: "Test Activity",
      nível: "Débutant",
      user: @user
    )
  end

  test "should be valid with valid attributes" do
    assert @activity.valid?
  end

  test "should require título" do
    @activity.título = nil
    assert_not @activity.valid?
    assert_includes @activity.errors[:título], "doit être rempli(e)"
  end

  test "should require minimum título length" do
    @activity.título = "ab"
    assert_not @activity.valid?
    assert_includes @activity.errors[:título], "est trop court (au moins 3 caractères)"
  end

  test "should require maximum título length" do
    @activity.título = "a" * 101
    assert_not @activity.valid?
    assert_includes @activity.errors[:título], "est trop long (pas plus de 100 caractères)"
  end

  test "should require nível" do
    @activity.nível = nil
    assert_not @activity.valid?
    assert_includes @activity.errors[:nível], "doit être rempli(e)"
  end

  test "should validate nível inclusion" do
    @activity.nível = "Invalid"
    assert_not @activity.valid?
    assert_includes @activity.errors[:nível], "n'est pas inclus(e) dans la liste"
  end

  test "should require user" do
    @activity.user = nil
    assert_not @activity.valid?
    assert_includes @activity.errors[:user], "doit exister"
  end

  test "should validate video_url format when present" do
    @activity.video_url = "invalid-url"
    assert_not @activity.valid?
    assert_includes @activity.errors[:video_url], "doit être une URL valide"
  end

  test "should accept valid video_url" do
    @activity.video_url = "https://www.youtube.com/watch?v=example"
    assert @activity.valid?
  end

  test "should validate imagem_url format when present" do
    @activity.imagem_url = "invalid-url"
    assert_not @activity.valid?
    assert_includes @activity.errors[:imagem_url], "doit être une URL valide"
  end

  test "should accept valid imagem_url" do
    @activity.imagem_url = "https://example.com/image.jpg"
    assert @activity.valid?
  end

  test "should allow blank URLs" do
    @activity.video_url = ""
    @activity.imagem_url = ""
    assert @activity.valid?
  end

  # Novos testes baseados na experiência do app de português
  test "should validate total questions limit to prevent timeout" do
    @activity.save!
    
    # Criar 26 questões para exceder o limite
    26.times do |i|
      @activity.questions.create!(
        conteúdo: "Question #{i}",
        tipo: "multiple_choice",
        display_order: i + 1
      )
    end
    
    # Recarregar para executar a validação
    @activity.reload
    assert_not @activity.valid?
    assert_includes @activity.errors[:base], "Une activité ne peut pas avoir plus de 25 questions pour éviter les problèmes de performance"
  end

  test "should allow activities with 25 or fewer questions" do
    @activity.save!
    
    # Criar exatamente 25 questões
    25.times do |i|
      @activity.questions.create!(
        conteúdo: "Question #{i}",
        tipo: "multiple_choice",
        display_order: i + 1
      )
    end
    
    @activity.reload
    assert @activity.valid?
  end

  test "should count all types of questions for limit validation" do
    @activity.save!
    
    # Criar diferentes tipos de questões que somam mais de 25
    10.times { |i| @activity.questions.create!(conteúdo: "Q#{i}", tipo: "multiple_choice", display_order: i) }
    
    # Criar fill_blanks com múltiplos blanks
    fill_blank = @activity.fill_blanks.create!(conteúdo: "Test", display_order: 11)
    10.times { |i| fill_blank.blanks.create!(correct_answer: "word#{i}", position: i) }
    
    # Criar sentence_orderings
    6.times { |i| @activity.sentence_orderings.create!(display_order: i + 12) }
    
    @activity.reload
    assert_not @activity.valid?
    assert_includes @activity.errors[:base], "Une activité ne peut pas avoir plus de 25 questions pour éviter les problèmes de performance"
  end
end
