class SentenceWord < ApplicationRecord
  belongs_to :sentence_ordering
  
  validates :word, presence: true
  validates :correct_position, presence: true, uniqueness: { scope: :sentence_ordering_id }
  validates :display_position, presence: true
end 