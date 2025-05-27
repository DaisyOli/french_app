class SentenceOrdering < ApplicationRecord
  belongs_to :activity
  has_many :sentence_words, dependent: :destroy
  
  # Método para processar a frase e extrair as palavras
  def process_words!
    return unless conteúdo.present?
    
    # Limpar palavras existentes
    sentence_words.destroy_all
    
    # Dividir a frase em palavras (removendo pontuação extra)
    words = conteúdo.strip.split(/\s+/)
    
    # Criar uma palavra para cada palavra encontrada
    words.each_with_index do |word, index|
      sentence_words.create!(
        word: word,
        correct_position: index + 1,
        display_position: index + 1 # Inicialmente na ordem correta
      )
    end
  end
  
  # Método para embaralhar as palavras para exibição
  def shuffled_words
    sentence_words.order(:display_position)
  end
  
  # Método para verificar se a ordem está correta
  def check_order(word_ids_in_order)
    return false if word_ids_in_order.length != sentence_words.count
    
    word_ids_in_order.each_with_index do |word_id, index|
      word = sentence_words.find_by(id: word_id)
      return false unless word && word.correct_position == (index + 1)
    end
    
    true
  end
end 