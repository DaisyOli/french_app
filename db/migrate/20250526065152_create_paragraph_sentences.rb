class CreateParagraphSentences < ActiveRecord::Migration[7.1]
  def change
    create_table :paragraph_sentences do |t|
      t.text :sentence
      t.integer :correct_position
      t.integer :display_position
      t.references :paragraph_ordering, null: false, foreign_key: true

      t.timestamps
    end
  end
end
