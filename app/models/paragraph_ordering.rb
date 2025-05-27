class ParagraphOrdering < ApplicationRecord
  belongs_to :activity
  has_many :paragraph_sentences, dependent: :destroy
  
  # Método para processar as sentenças
  def process_sentences!
    return unless paragraph_sentences.any?
    
    # Reordenar as posições corretas baseado na ordem atual
    paragraph_sentences.order(:correct_position).each_with_index do |sentence, index|
      sentence.update!(correct_position: index + 1)
    end
  end
  
  # Método para embaralhar as sentenças para exibição
  def shuffled_sentences
    paragraph_sentences.order(:display_position)
  end
  
  # Método para verificar se a ordem está correta
  def check_order(sentence_ids_in_order)
    return false if sentence_ids_in_order.length != paragraph_sentences.count
    
    sentence_ids_in_order.each_with_index do |sentence_id, index|
      sentence = paragraph_sentences.find_by(id: sentence_id)
      return false unless sentence && sentence.correct_position == (index + 1)
    end
    
    true
  end
end 