class AddProfessionalTypeToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :professional_type, :string
  end
end
