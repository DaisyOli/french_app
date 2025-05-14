class AddOrderToActivityElements < ActiveRecord::Migration[7.1]
  def change
    add_column :activities, :video_order, :integer, default: 1
    add_column :activities, :imagem_order, :integer, default: 2
    add_column :activities, :texte_order, :integer, default: 3
    
    # Adicionar campo de ordem para elementos relacionados
    add_column :statements, :display_order, :integer
    add_column :questions, :display_order, :integer
    add_column :suggestions, :display_order, :integer
    
    # Definir valores iniciais com base na ordem atual
    reversible do |dir|
      dir.up do
        # Inicializar ordens para elementos existentes
        execute <<-SQL
          UPDATE statements SET display_order = id;
          UPDATE questions SET display_order = id;
          UPDATE suggestions SET display_order = id;
        SQL
      end
    end
  end
end
