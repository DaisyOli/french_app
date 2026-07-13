class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :validatable
         
  has_many :activities, dependent: :destroy
  has_many :students, foreign_key: :invited_by_id

  validates :email, presence: true, uniqueness: true

  before_destroy :unlink_students

  private

  # Ao apagar um professor (painel admin), os alunos vinculados a ele NÃO
  # são apagados — só desvinculados. Mesma convenção já usada em
  # TeacherStudentsController#remove (desvincular, não destruir).
  def unlink_students
    students.update_all(invited_by_id: nil, invited_by_type: nil)
  end
end
