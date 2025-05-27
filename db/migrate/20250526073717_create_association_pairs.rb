class CreateAssociationPairs < ActiveRecord::Migration[7.1]
  def change
    create_table :association_pairs do |t|
      t.references :column_association, null: false, foreign_key: true
      t.string :item_a, null: false
      t.string :item_b, null: false
      t.integer :pair_order, null: false

      t.timestamps
    end
    
    add_index :association_pairs, [:column_association_id, :pair_order], unique: true
  end
end
