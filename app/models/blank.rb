class Blank < ApplicationRecord
  belongs_to :fill_blank
  
  validates :position, presence: true, uniqueness: { scope: :fill_blank_id }
  
  # Método para verificar se uma resposta está correta (case insensitive)
  def correct?(answer)
    return false if answer.blank? || correct_answer.blank?
    
    # Normalizar ambas as strings para comparação
    normalize_answer(answer) == normalize_answer(correct_answer)
  end
  
  private
  
  def normalize_answer(text)
    text.to_s
      .strip                              # Remove espaços no início e fim
      .downcase                           # Converte para minúsculas
      .gsub(/\s+/, ' ')                   # Substitui múltiplos espaços por um só
      .gsub(/[.,;:!?'"()\[\]{}]/, '')     # Remove pontuação
      .gsub(/[àáâãäå]/, 'a')
      .gsub(/[èéêë]/, 'e')
      .gsub(/[ìíîï]/, 'i')
      .gsub(/[òóôõö]/, 'o')
      .gsub(/[ùúûü]/, 'u')
      .gsub(/[ç]/, 'c')
      .gsub(/[ñ]/, 'n')
      .strip                              # Remove espaços novamente após limpeza
  end
end
