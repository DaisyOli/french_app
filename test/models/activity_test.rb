require "test_helper"

class ActivityTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)  # Usando fixture existente
    @activity = Activity.new(
      título: "Test Activity",
      nível: "A1",
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

  test "should accept all valid níveis" do
    valid_niveis = %w[A1 A2 B1 B2 C1 C2]
    valid_niveis.each do |nivel|
      @activity.nível = nivel
      assert @activity.valid?, "#{nivel} should be a valid nível"
    end
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

  # Sprint do redesenho do show.html.erb (2026-07-13): ordered_elements /
  # next_display_order / previous_element_dom_id substituem a lógica de
  # ordenação que estava reimplementada em 7 controllers diferentes.
  test "ordered_elements returns every exercise type sorted by display_order" do
    @activity.save!
    question = @activity.questions.create!(conteúdo: "Q", tipo: "multiple_choice", display_order: 3)
    statement = @activity.statements.create!(conteúdo: "S", display_order: 1)
    column_association = @activity.column_associations.create!(title: "T", column_a_title: "A", column_b_title: "B", display_order: 2)

    assert_equal [statement, column_association, question], @activity.ordered_elements
  end

  test "ordered_elements excludes unsaved records built in memory" do
    @activity.save!
    @activity.suggestions.new(conteúdo: "rascunho não salvo")

    assert_empty @activity.ordered_elements
  end

  test "next_display_order considers media fields and every exercise type" do
    @activity.video_url = "https://www.youtube.com/watch?v=example"
    @activity.video_order = 5
    @activity.save!
    @activity.statements.create!(conteúdo: "S", display_order: 2)

    assert_equal 6, @activity.next_display_order
  end

  test "next_display_order returns 1 for a brand new activity with nothing yet" do
    @activity.save!
    assert_equal 1, @activity.next_display_order
  end

  # Achado da faxina: 6 dos 7 controllers nunca consideravam
  # column_associations como candidato a "elemento anterior" ao apagar algo
  # — corrigido centralizando em previous_element_dom_id.
  test "previous_element_dom_id considers column_associations as a candidate" do
    @activity.save!
    column_association = @activity.column_associations.create!(title: "T", column_a_title: "A", column_b_title: "B", display_order: 1)
    statement = @activity.statements.create!(conteúdo: "S", display_order: 2)

    assert_equal "column-association-#{column_association.id}",
                 @activity.previous_element_dom_id(statement.display_order, exclude: statement)
  end

  test "previous_element_dom_id considers media sections as candidates" do
    @activity.video_url = "https://www.youtube.com/watch?v=example"
    @activity.video_order = 1
    @activity.save!
    statement = @activity.statements.create!(conteúdo: "S", display_order: 2)

    assert_equal "video-section", @activity.previous_element_dom_id(statement.display_order, exclude: statement)
  end

  test "previous_element_dom_id returns nil when nothing comes before" do
    @activity.save!
    statement = @activity.statements.create!(conteúdo: "S", display_order: 1)

    assert_nil @activity.previous_element_dom_id(statement.display_order, exclude: statement)
  end
end
