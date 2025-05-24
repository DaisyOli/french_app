class AddStudentToCompletedActivities < ActiveRecord::Migration[7.1]
  def change
    add_reference :completed_activities, :student, null: true, foreign_key: true
    change_column_null :completed_activities, :user_id, true
    
    # Remove o índice único antigo
    remove_index :completed_activities, [:user_id, :activity_id], if_exists: true
    
    # Adiciona novos índices únicos
    add_index :completed_activities, [:user_id, :activity_id], unique: true, where: "user_id IS NOT NULL"
    add_index :completed_activities, [:student_id, :activity_id], unique: true, where: "student_id IS NOT NULL"
  end
end 