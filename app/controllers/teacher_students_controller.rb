class TeacherStudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student, only: [:show, :update_level, :remove, :attestation]

  def index
    @students = current_user.students.order(created_at: :desc)
    @students = @students.where("email ILIKE ?", "%#{params[:search]}%") if params[:search].present?

    student_ids = @students.pluck(:id)
    @attempts_count = CompletedActivity.where(student_id: student_ids).group(:student_id).count
    @average_scores = CompletedActivity.where(student_id: student_ids).group(:student_id).average(:percentage)
    @last_activity = CompletedActivity.where(student_id: student_ids).group(:student_id).maximum(:completed_at)
  end

  def show
    @completed_activities = @student.completed_activities
                                     .includes(:activity)
                                     .order(completed_at: :desc)
    @total_completed = @completed_activities.count
    avg = @completed_activities.average(:percentage)
    @average_score = avg ? avg.round(1) : 0
    @best_score = @completed_activities.maximum(:percentage)&.round(1) || 0
    @training_minutes = teacher_completed_activities.to_a.sum { |ca| ca.duration_minutes || 0 }
  end

  def attestation
    @completed_activities = teacher_completed_activities.order(completed_at: :asc).to_a
    @total_minutes = @completed_activities.sum { |ca| ca.duration_minutes || 0 }
  end

  def update_level
    if @student.update(nível: params.require(:student).permit(:nível)[:nível].presence)
      redirect_to teacher_student_path(@student), notice: "Niveau mis à jour."
    else
      redirect_to teacher_student_path(@student), alert: "Erreur lors de la mise à jour du niveau."
    end
  end

  def remove
    @student.update(invited_by_id: nil, invited_by_type: nil)
    redirect_to teacher_students_path, notice: "Étudiant retiré de votre liste."
  end

  private

  def set_student
    @student = current_user.students.find(params[:id])
  end

  # Só conta atividades que o próprio professor criou — a mesma pessoa
  # que assina o atestado é a que ministrou a formação.
  def teacher_completed_activities
    @student.completed_activities
            .joins(:activity)
            .where(activities: { user_id: current_user.id })
            .includes(:activity)
  end
end
