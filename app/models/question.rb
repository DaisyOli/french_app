class Question < ApplicationRecord
  belongs_to :activity
  has_many :alternatives, dependent: :destroy
end
