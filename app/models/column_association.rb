class ColumnAssociation < ApplicationRecord
  belongs_to :activity
  has_many :association_pairs, dependent: :destroy
  
  validates :title, presence: true
  validates :column_a_title, presence: true
  validates :column_b_title, presence: true
  
  scope :ordered, -> { order(:display_order, :id) }
  
  before_create :set_display_order
  
  private
  
  def set_display_order
    return if display_order.present?
    
    # Encontrar a maior ordem entre todos os elementos da atividade
    max_orders = []
    max_orders << activity.video_order if activity.video_url.present?
    max_orders << activity.imagem_order if activity.imagem_url.present?
    max_orders << activity.texte_order if activity.texte.present?
    max_orders << activity.statements.maximum(:display_order) || 0
    max_orders << activity.questions.maximum(:display_order) || 0
    max_orders << activity.suggestions.maximum(:display_order) || 0
    max_orders << activity.fill_blanks.maximum(:display_order) || 0
    max_orders << activity.sentence_orderings.maximum(:display_order) || 0
    max_orders << activity.paragraph_orderings.maximum(:display_order) || 0
    max_orders << activity.column_associations.maximum(:display_order) || 0
    
    self.display_order = (max_orders.compact.max || 0) + 1
  end
end 