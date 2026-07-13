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

    self.display_order = activity.next_display_order
  end
end 