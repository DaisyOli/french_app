class CompletedActivity < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :student, optional: true
  belongs_to :activity

  validates :score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_questions, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :percentage, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :completed_at, presence: true
  
  validate :must_belong_to_user_or_student

  # Calcular a porcentagem ANTES das validações
  before_validation :calculate_percentage
  
  # Permitir refazer atividades - manter apenas o último resultado
  before_save :remove_previous_completion

  # Atualizar streak do estudante após salvar
  after_save :update_student_streak

  private

  def calculate_percentage
    return unless score && total_questions && total_questions > 0
    self.percentage = (score.to_f / total_questions * 100).round(2)
  end

  def remove_previous_completion
    if student.present?
      # Remove completions anteriores desta atividade para este estudante
      CompletedActivity.where(student: student, activity: activity).where.not(id: id).destroy_all
    elsif user.present?
      # Remove completions anteriores desta atividade para este usuário
      CompletedActivity.where(user: user, activity: activity).where.not(id: id).destroy_all
    end
  end

  def must_belong_to_user_or_student
    unless user.present? ^ student.present? # XOR - deve pertencer a um OU outro, não ambos
      errors.add(:base, "deve pertencer a um usuário ou estudante, mas não ambos")
    end
  end

  def update_student_streak
    student&.update_streak!
  end
end 