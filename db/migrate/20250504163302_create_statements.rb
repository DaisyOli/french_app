class CreateStatements < ActiveRecord::Migration[7.1]
  def change
    create_table :statements do |t|
      t.text :conteúdo
      t.references :activity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
