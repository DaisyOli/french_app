class AddNameToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :name, :string
  end
end
