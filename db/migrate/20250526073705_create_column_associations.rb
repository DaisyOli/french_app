class CreateColumnAssociations < ActiveRecord::Migration[7.1]
  def change
    create_table :column_associations do |t|
      t.references :activity, null: false, foreign_key: true
      t.string :title, null: false
      t.text :instruction
      t.string :column_a_title, default: "Colonne A"
      t.string :column_b_title, default: "Colonne B"
      t.integer :display_order

      t.timestamps
    end
  end
end
