class AdminAuditLog < ApplicationRecord
  belongs_to :admin, class_name: "User"

  validates :action, presence: true
  validates :target_description, presence: true
end
