class ActivityRating < ApplicationRecord
  belongs_to :student
  belongs_to :activity

  validates :stars, presence: true, inclusion: { in: 1..5, message: "doit être entre 1 et 5" }
  validates :student_id, uniqueness: { scope: :activity_id, message: "a déjà évalué cette activité" }
  validates :comment, length: { maximum: 500 }

  scope :recent, -> { order(created_at: :desc) }
  scope :with_comments, -> { where.not(comment: [nil, '']) }
  scope :by_stars, ->(stars) { where(stars: stars) }

  # Callbacks para invalidar cache - otimizado
  after_save :invalidate_activity_cache
  after_destroy :invalidate_activity_cache

  def self.average_rating
    return 0 if count.zero?
    average(:stars).round(1)
  end

  def formatted_date
    created_at.strftime("%d/%m/%Y à %H:%M")
  end

  private

  def invalidate_activity_cache
    # Invalidar cache da atividade específica
    activity.invalidate_all_cache if activity.present?
    
    # Invalidar cache do dashboard apenas se necessário
    Rails.cache.delete("activities_dashboard_stats")
    Rails.cache.delete("recent_ratings")
    
    # Log para monitoramento
    Rails.logger.info "Cache invalidado para activity_id: #{activity_id}" if Rails.env.production?
  end
end 