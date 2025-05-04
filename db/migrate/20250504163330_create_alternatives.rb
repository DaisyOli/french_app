class CreateAlternatives < ActiveRecord::Migration[7.1]
  def change
    create_table :alternatives do |t|
      t.text :conteúdo
      t.boolean :correta, default: false
      t.references :question, null: false, foreign_key: true

      t.timestamps
    end
  end
end
