class AddTexteToActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :activities, :texte, :text
  end
end
