require "test_helper"

class StudentTest < ActiveSupport::TestCase
  def setup
    @student = Student.new(
      email: "student@example.com",
      password: "password123"
    )
  end

  test "should be valid with valid attributes" do
    assert @student.valid?
  end

  test "should require email" do
    @student.email = nil
    assert_not @student.valid?
    assert_includes @student.errors[:email], "doit être rempli(e)"
  end

  test "should require unique email" do
    @student.save!
    duplicate_student = Student.new(email: @student.email, password: "password123")
    assert_not duplicate_student.valid?
    assert_includes duplicate_student.errors[:email], "est déjà utilisé(e)"
  end

  test "should initialize with zero streaks" do
    assert_equal 0, @student.current_streak
    assert_equal 0, @student.best_streak
    assert_nil @student.last_activity_date
  end

  test "update_streak! should set streak to 1 for first activity" do
    @student.save!
    @student.update_streak!
    
    assert_equal 1, @student.current_streak
    assert_equal 1, @student.best_streak
    assert_equal Date.current, @student.last_activity_date
  end

  test "update_streak! should not change streak for same day activity" do
    @student.save!
    @student.update_streak!
    initial_streak = @student.current_streak
    
    @student.update_streak!
    
    assert_equal initial_streak, @student.current_streak
  end

  test "update_streak! should increment for consecutive days" do
    @student.save!
    @student.update(last_activity_date: Date.current - 1.day, current_streak: 1, best_streak: 1)
    
    @student.update_streak!
    
    assert_equal 2, @student.current_streak
    assert_equal 2, @student.best_streak
    assert_equal Date.current, @student.last_activity_date
  end

  test "update_streak! should reset for non-consecutive days" do
    @student.save!
    @student.update(last_activity_date: Date.current - 3.days, current_streak: 5, best_streak: 5)
    
    @student.update_streak!
    
    assert_equal 1, @student.current_streak
    assert_equal 5, @student.best_streak # best_streak should remain
    assert_equal Date.current, @student.last_activity_date
  end

  test "current_trophy should return correct trophy for different streaks" do
    @student.current_streak = 0
    assert_equal "Débutant", @student.current_trophy[:name]
    assert_equal "🎯", @student.current_trophy[:icon]

    @student.current_streak = 3
    assert_equal "Croissant", @student.current_trophy[:name]
    assert_equal "🥐", @student.current_trophy[:icon]

    @student.current_streak = 7
    assert_equal "Baguette", @student.current_trophy[:name]
    assert_equal "🥖", @student.current_trophy[:icon]

    @student.current_streak = 14
    assert_equal "Fromage", @student.current_trophy[:name]
    assert_equal "🧀", @student.current_trophy[:icon]

    @student.current_streak = 30
    assert_equal "Vin", @student.current_trophy[:name]
    assert_equal "🍷", @student.current_trophy[:icon]

    @student.current_streak = 60
    assert_equal "Tour Eiffel", @student.current_trophy[:name]
    assert_equal "🗼", @student.current_trophy[:icon]
  end

  test "next_trophy_info should return correct next trophy information" do
    @student.current_streak = 1
    next_trophy = @student.next_trophy_info
    assert_equal 3, next_trophy[:target]
    assert_equal "Croissant", next_trophy[:name]
    assert_equal 2, next_trophy[:needed]

    @student.current_streak = 5
    next_trophy = @student.next_trophy_info
    assert_equal 7, next_trophy[:target]
    assert_equal "Baguette", next_trophy[:name]
    assert_equal 2, next_trophy[:needed]
  end

  test "nível should accept blank and valid CEFR levels" do
    assert @student.valid?

    Student::CEFR_LEVELS.each do |level|
      @student.nível = level
      assert @student.valid?, "#{level} deveria ser um nível válido"
    end
  end

  test "nível should reject invalid values" do
    @student.nível = "Z9"
    assert_not @student.valid?
  end

  test "accessible_levels should return all levels when nível is blank" do
    # Decisão deliberada da Sprint 6: aluno sem nível (antigo, de antes desta
    # coluna existir, ou convite sem nível escolhido) tem acesso total, pra
    # não travar quem já usava o app antes desta feature existir.
    @student.nível = nil
    assert_equal Student::CEFR_LEVELS, @student.accessible_levels
  end

  test "accessible_levels should be cumulative up to the assigned level" do
    @student.nível = "B1"
    assert_equal %w[A1 A2 B1], @student.accessible_levels
  end

  test "accessible_levels should return only A1 for the lowest level" do
    @student.nível = "A1"
    assert_equal %w[A1], @student.accessible_levels
  end

  test "accessible_levels should return all levels for the highest level" do
    @student.nível = "C2"
    assert_equal Student::CEFR_LEVELS, @student.accessible_levels
  end

  test "professional_type should accept blank and OPCO/eCPF" do
    assert @student.valid?

    Student::PROFESSIONAL_TYPES.each do |type|
      @student.professional_type = type
      assert @student.valid?, "#{type} deveria ser um percurso profissional válido"
    end
  end

  test "professional_type should reject invalid values" do
    @student.professional_type = "INVALID"
    assert_not @student.valid?
  end

  test "motivational_message should return appropriate message" do
    @student.current_streak = 0
    assert_includes @student.motivational_message, "Commencez"

    @student.current_streak = 1
    assert_includes @student.motivational_message, "Excellent"

    @student.current_streak = 5
    assert_includes @student.motivational_message, "croissant"

    @student.current_streak = 10
    assert_includes @student.motivational_message, "baguette"
  end
end
