class AddNivelToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :nível, :string
  end
end
