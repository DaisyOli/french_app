class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :activities, dependent: :destroy
  has_many :students, foreign_key: :invited_by_id

  validates :email, presence: true, uniqueness: true
end
