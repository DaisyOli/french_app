class AddFieldsToCompletedActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :completed_activities, :total_questions, :integer
    add_column :completed_activities, :percentage, :decimal
  end
end
