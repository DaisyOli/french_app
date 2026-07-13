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
  
  # Tipos de exercício com ordem própria dentro da atividade — não inclui
  # vídeo/imagem/texto, que são campos da própria Activity (video_order/
  # imagem_order/texte_order), tratados à parte nos métodos abaixo.
  ORDERED_ELEMENT_ASSOCIATIONS = %i[statements questions suggestions fill_blanks
                                     sentence_orderings paragraph_orderings column_associations].freeze

  # Prefixo do id HTML usado pra rolar a tela até o elemento — mesma
  # convenção que já existia espalhada pelos controllers e pela view
  # (fill_blank/sentence_ordering/paragraph_ordering/column_association usam
  # hífen, não os nomes das classes).
  ELEMENT_DOM_ID_PREFIXES = {
    "Statement" => "statement",
    "Question" => "question",
    "Suggestion" => "suggestion",
    "FillBlank" => "fill-blank",
    "SentenceOrdering" => "sentence-ordering",
    "ParagraphOrdering" => "paragraph-ordering",
    "ColumnAssociation" => "column-association",
  }.freeze

  # Todos os exercícios da atividade (sem vídeo/imagem/texto), na ordem em
  # que aparecem pro professor. display_order pode ser nil em registros bem
  # antigos, por isso o fallback pro id. Filtra só os já salvos: um
  # controller que chama @activity.suggestions.new(...) antes de calcular a
  # próxima ordem deixaria o novo registro (sem id ainda) no meio da lista.
  def ordered_elements
    ORDERED_ELEMENT_ASSOCIATIONS.flat_map { |assoc| send(assoc) }
                                 .select(&:persisted?)
                                 .sort_by { |element| element.display_order || element.id }
  end

  # Próximo display_order livre, considerando TODOS os elementos com posição
  # própria na sequência — vídeo/imagem/texto e os 7 tipos de exercício.
  def next_display_order
    orders = []
    orders << video_order if video_url.present?
    orders << imagem_order if imagem_url.present?
    orders << texte_order if texte.present?
    orders.concat(ordered_elements.map { |el| el.display_order || el.id })
    (orders.compact.max || 0) + 1
  end

  # Id HTML do elemento imediatamente anterior a uma certa ordem — usado pra
  # rolar a tela até o elemento certo depois de apagar algo. Considera
  # vídeo/imagem/texto e os 7 tipos de exercício (achado na Sprint do
  # redesenho: antes, 6 dos 7 controllers nunca consideravam
  # column_associations como candidato, podendo rolar pro lugar errado).
  # Passe exclude: pro próprio elemento sendo removido (ainda não destruído
  # no banco quando este método é chamado).
  def previous_element_dom_id(before_order, exclude: nil)
    candidates = []
    candidates << ["video-section", video_order] if video_url.present? && video_order < before_order
    candidates << ["image-section", imagem_order] if imagem_url.present? && imagem_order < before_order
    candidates << ["texte-section", texte_order] if texte.present? && texte_order < before_order

    ordered_elements.each do |element|
      next if exclude && element == exclude

      order = element.display_order || element.id
      next unless order < before_order

      prefix = ELEMENT_DOM_ID_PREFIXES.fetch(element.class.name)
      candidates << ["#{prefix}-#{element.id}", order]
    end

    candidates.max_by { |(_, order)| order }&.first
  end

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
