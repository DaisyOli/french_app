class CreateCompletedActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :completed_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.references :activity, null: false, foreign_key: true
      t.integer :score
      t.datetime :completed_at

      t.timestamps
    end

    add_index :completed_activities, [:user_id, :activity_id], unique: true
  end
end 