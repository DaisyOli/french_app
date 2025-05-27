class UpdateColumnAssociationDefaults < ActiveRecord::Migration[7.1]
  def change
    change_column_default :column_associations, :column_a_title, "Primeira coluna"
    change_column_default :column_associations, :column_b_title, "Segunda coluna"
  end
end
