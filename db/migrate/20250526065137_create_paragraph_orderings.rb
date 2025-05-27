class CreateParagraphOrderings < ActiveRecord::Migration[7.1]
  def change
    create_table :paragraph_orderings do |t|
      t.string :titre
      t.text :instruction
      t.references :activity, null: false, foreign_key: true
      t.integer :display_order

      t.timestamps
    end
  end
end
