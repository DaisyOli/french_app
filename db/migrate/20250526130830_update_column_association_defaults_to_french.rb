class UpdateColumnAssociationDefaultsToFrench < ActiveRecord::Migration[7.1]
  def change
    change_column_default :column_associations, :column_a_title, "Première colonne"
    change_column_default :column_associations, :column_b_title, "Seconde colonne"
  end
end
