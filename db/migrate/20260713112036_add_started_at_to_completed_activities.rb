class AddStartedAtToCompletedActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :completed_activities, :started_at, :datetime
  end
end
