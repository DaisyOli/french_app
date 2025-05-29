class CreateActivityRatings < ActiveRecord::Migration[7.1]
  def change
    create_table :activity_ratings do |t|
      t.references :student, null: false, foreign_key: true
      t.references :activity, null: false, foreign_key: true
      t.integer :stars, null: false
      t.text :comment

      t.timestamps
    end
    
    # Índice único para garantir uma avaliação por aluno por atividade
    add_index :activity_ratings, [:student_id, :activity_id], unique: true
    
    # Validação no banco de dados para estrelas (1-5)
    add_check_constraint :activity_ratings, "stars >= 1 AND stars <= 5", name: "stars_range_check"
  end
end
