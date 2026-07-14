class AddCompetenciaToActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :activities, :competência, :string
  end
end
