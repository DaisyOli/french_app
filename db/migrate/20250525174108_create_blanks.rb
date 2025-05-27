class CreateBlanks < ActiveRecord::Migration[7.1]
  def change
    create_table :blanks do |t|
      t.integer :position
      t.string :correct_answer
      t.references :fill_blank, null: false, foreign_key: true

      t.timestamps
    end
  end
end
