class Admin::DashboardController < Admin::BaseController
  def index
    @total_teachers = User.count
    @total_students = Student.count
    @total_activities = Activity.count
    @total_attempts = CompletedActivity.count

    @teachers = User.order(:email)
    teacher_ids = @teachers.pluck(:id)
    @activities_count = Activity.where(user_id: teacher_ids).group(:user_id).count
    @students_count = Student.where(invited_by_id: teacher_ids, invited_by_type: "User").group(:invited_by_id).count
    @last_activity_at = Activity.where(user_id: teacher_ids).group(:user_id).maximum(:created_at)
    @attempts_count = CompletedActivity.joins(:activity).where(activities: { user_id: teacher_ids }).group("activities.user_id").count
    @average_score = CompletedActivity.joins(:activity).where(activities: { user_id: teacher_ids }).group("activities.user_id").average(:percentage)

    @students = Student.order(:email)
    student_ids = @students.pluck(:id)
    @completed_count = CompletedActivity.where(student_id: student_ids).group(:student_id).count
    # .includes só depois do .pluck acima: encadear .pluck numa relação com
    # .includes de associação polimórfica (invited_by) força o Rails a
    # tentar um eager_load via JOIN, que não suporta polimorfismo.
    @students = @students.includes(:invited_by)

    @recent_logs = AdminAuditLog.includes(:admin).order(created_at: :desc).limit(15)
  end
end
