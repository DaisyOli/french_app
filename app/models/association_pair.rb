class AssociationPair < ApplicationRecord
  belongs_to :column_association
  
  validates :item_a, presence: true
  validates :item_b, presence: true
  validates :pair_order, presence: true, uniqueness: { scope: :column_association_id }
  
  scope :ordered, -> { order(:pair_order) }
end 