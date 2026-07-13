require "test_helper"

class CompletedActivityTest < ActiveSupport::TestCase
  def setup
    @student = students(:one)
    @activity = activities(:one)
  end

  test "duration_minutes should be nil without started_at" do
    ca = CompletedActivity.new(started_at: nil, completed_at: Time.current)
    assert_nil ca.duration_minutes
  end

  test "duration_minutes should be nil without completed_at" do
    ca = CompletedActivity.new(started_at: Time.current, completed_at: nil)
    assert_nil ca.duration_minutes
  end

  test "duration_minutes should compute minutes between started_at and completed_at" do
    ca = CompletedActivity.new(started_at: 45.minutes.ago, completed_at: Time.current)
    assert_equal 45, ca.duration_minutes
  end

  test "duration_minutes should cap at 120 minutes per session" do
    # Sessão de 3h não deve inflar o total do atestado de formation (Sprint 8) —
    # mesmo critério do practice-br, protege contra aba esquecida aberta.
    ca = CompletedActivity.new(started_at: 180.minutes.ago, completed_at: Time.current)
    assert_equal 120, ca.duration_minutes
  end

  test "percentage should be calculated from score and total_questions" do
    ca = CompletedActivity.new(student: @student, activity: @activity, score: 7, total_questions: 10, completed_at: Time.current)
    ca.valid?
    assert_equal 70.0, ca.percentage
  end
end
