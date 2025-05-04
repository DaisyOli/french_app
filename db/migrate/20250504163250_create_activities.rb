class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.string :título
      t.string :nível
      t.text :texto
      t.string :video_url
      t.string :imagem_url
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
