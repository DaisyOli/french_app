class CreateSentenceOrderings < ActiveRecord::Migration[7.1]
  def change
    create_table :sentence_orderings do |t|
      t.text :conteúdo
      t.references :activity, null: false, foreign_key: true
      t.integer :display_order

      t.timestamps
    end
  end
end
