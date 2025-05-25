class AddStreakToStudents < ActiveRecord::Migration[7.1]
  def change
    add_column :students, :current_streak, :integer, default: 0
    add_column :students, :best_streak, :integer, default: 0
    add_column :students, :last_activity_date, :date
  end
end
