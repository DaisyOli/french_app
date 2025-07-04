class AddSlugToActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :activities, :slug, :string
    add_index :activities, :slug, unique: true
    
    # Popular slugs para atividades existentes
    reversible do |dir|
      dir.up do
        Activity.reset_column_information
        Activity.find_each do |activity|
          activity.update_column(:slug, generate_slug(activity.título))
        end
      end
    end
  end
  
  private
  
  def generate_slug(title)
    return 'atividade' if title.blank?
    
    # Converter para minúsculas e substituir caracteres especiais
    slug = title.to_s.downcase
    
    # Substituir caracteres acentuados
    slug = slug.tr('àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ', 'aaaaaaeceeeeiiiidnoooooouuuuyty')
    
    # Remover caracteres que não são letras, números ou espaços
    slug = slug.gsub(/[^a-z0-9\s]/, '')
    
    # Substituir espaços por hífens
    slug = slug.gsub(/\s+/, '-')
    
    # Remover hífens duplos
    slug = slug.gsub(/-+/, '-')
    
    # Remover hífens do início e fim
    slug = slug.strip.gsub(/^-|-$/, '')
    
    # Garantir que não fique vazio
    slug = 'atividade' if slug.blank?
    
    slug
  end
end
