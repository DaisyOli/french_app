class CreateSentenceWords < ActiveRecord::Migration[7.1]
  def change
    create_table :sentence_words do |t|
      t.string :word
      t.integer :correct_position
      t.integer :display_position
      t.references :sentence_ordering, null: false, foreign_key: true

      t.timestamps
    end
  end
end
