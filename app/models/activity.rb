class Activity < ApplicationRecord
  belongs_to :user
  has_many :statements, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :suggestions, dependent: :destroy
  has_many :fill_blanks, dependent: :destroy
  has_many :sentence_orderings, dependent: :destroy
  has_many :paragraph_orderings, dependent: :destroy
  has_many :column_associations, dependent: :destroy
  has_many :completed_activities, dependent: :destroy
  has_many :activity_ratings, dependent: :destroy

  validates :título, presence: true, length: { minimum: 3, maximum: 100 }
  validates :nível, presence: true, inclusion: { in: %w[A1 A2 B1 B2 C1 C2] }
  validates :user, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/, message: "deve conter apenas letras minúsculas, números e hífens" }
  
  # Validações condicionais para URLs
  validates :video_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "doit être une URL valide" }, allow_blank: true
  validates :imagem_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "doit être une URL valide" }, allow_blank: true
  
  # Validação para prevenir timeout em produção (baseado na experiência do app de português)
  validate :total_questions_limit
  
  # Callbacks para geração automática do slug
  before_validation :generate_slug, if: :should_generate_slug?
  before_validation :ensure_unique_slug
  
  # Método para URLs amigáveis - retorna slug em vez de ID
  def to_param
    slug
  end
  
  # Método de classe para buscar por ID ou slug
  def self.find_by_param(param)
    # Tenta primeiro por slug, depois por ID para compatibilidade
    find_by(slug: param) || find(param)
  rescue ActiveRecord::RecordNotFound
    # Se não encontrar por ID, tenta por slug novamente (caso o parâmetro tenha caracteres especiais)
    find_by!(slug: param)
  end
  
  # Métodos para avaliações - otimizados para reduzir pressão no Redis
  def average_rating
    return 0 if activity_ratings.count.zero?
    
    # Cache com expiração mais longa para reduzir pressão no Redis
    Rails.cache.fetch("activity_#{id}_average_rating", expires_in: 30.minutes) do
      activity_ratings.average(:stars)&.round(1) || 0
    end
  end

  def ratings_count
    # Cache com expiração mais longa
    Rails.cache.fetch("activity_#{id}_ratings_count", expires_in: 30.minutes) do
      activity_ratings.count
    end
  end

  def rating_by_student(student)
    # Cache individual por estudante por 1 hora
    Rails.cache.fetch("activity_#{id}_student_#{student.id}_rating", expires_in: 1.hour) do
      activity_ratings.find_by(student: student)
    end
  end
  
  # Método para invalidar todo o cache da atividade
  def invalidate_all_cache
    Rails.cache.delete("activity_#{id}_average_rating")
    Rails.cache.delete("activity_#{id}_ratings_count")
    # Invalidar cache de ratings por estudante seria complexo, deixamos expirar naturalmente
  end
  
  private
  
  def should_generate_slug?
    self[:slug].blank? || título_changed?
  end
  
  def generate_slug
    return if título.blank?
    
    base_slug = título.to_s.downcase
    
    # Substituir caracteres acentuados
    base_slug = base_slug.tr('àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ', 'aaaaaaeceeeeiiiidnoooooouuuuyty')
    
    # Remover caracteres que não são letras, números ou espaços
    base_slug = base_slug.gsub(/[^a-z0-9\s]/, '')
    
    # Substituir espaços por hífens
    base_slug = base_slug.gsub(/\s+/, '-')
    
    # Remover hífens duplos
    base_slug = base_slug.gsub(/-+/, '-')
    
    # Remover hífens do início e fim
    base_slug = base_slug.strip.gsub(/^-|-$/, '')
    
    # Garantir que não fique vazio
    base_slug = 'atividade' if base_slug.blank?
    
    self[:slug] = base_slug
  end
  
  def ensure_unique_slug
    return if self[:slug].blank?
    
    original_slug = self[:slug]
    counter = 1
    
    # Verificar se já existe outro registro com o mesmo slug
    while Activity.where(slug: self[:slug]).where.not(id: id).exists?
      self[:slug] = "#{original_slug}-#{counter}"
      counter += 1
    end
  end
  
  def total_questions_limit
    total_questions = questions.count + 
                     fill_blanks.sum { |fb| fb.blanks.count } +
                     sentence_orderings.count +
                     paragraph_orderings.sum { |po| po.paragraph_sentences.count } +
                     column_associations.sum { |ca| ca.association_pairs.count }
    
    if total_questions > 25
      errors.add(:base, "Une activité ne peut pas avoir plus de 25 questions pour éviter les problèmes de performance")
    end
  end
end
