class ParagraphSentence < ApplicationRecord
  belongs_to :paragraph_ordering
  
  validates :sentence, presence: true
  validates :correct_position, presence: true, uniqueness: { scope: :paragraph_ordering_id }
  validates :display_position, presence: true
end 