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

  validates :título, presence: true, length: { minimum: 3, maximum: 100 }
  validates :nível, presence: true, inclusion: { in: %w[A1 A2 B1 B2 C1 C2] }
  validates :user, presence: true
  
  # Validações condicionais para URLs
  validates :video_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "doit être une URL valide" }, allow_blank: true
  validates :imagem_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "doit être une URL valide" }, allow_blank: true
  
  # Validação para prevenir timeout em produção (baseado na experiência do app de português)
  validate :total_questions_limit
  
  private
  
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
