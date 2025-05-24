class CompletedActivity < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :student, optional: true
  belongs_to :activity

  validates :score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :completed_at, presence: true
  
  validate :must_belong_to_user_or_student
  validate :unique_completion_per_user_or_student

  private

  def must_belong_to_user_or_student
    unless user.present? ^ student.present? # XOR - deve pertencer a um OU outro, não ambos
      errors.add(:base, "deve pertencer a um usuário ou estudante, mas não ambos")
    end
  end

  def unique_completion_per_user_or_student
    if user.present?
      if CompletedActivity.where(user: user, activity: activity).where.not(id: id).exists?
        errors.add(:user, "já completou esta atividade")
      end
    elsif student.present?
      if CompletedActivity.where(student: student, activity: activity).where.not(id: id).exists?
        errors.add(:student, "já completou esta atividade")
      end
    end
  end
end 