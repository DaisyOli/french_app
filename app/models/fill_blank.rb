class FillBlank < ApplicationRecord
  belongs_to :activity
  has_many :blanks, dependent: :destroy
  
  # Método para processar o texto e extrair as lacunas
  def process_blanks!
    return unless conteúdo.present?
    
    # Limpar blanks existentes
    blanks.destroy_all
    
    # Encontrar todas as lacunas (marcadas com ___)
    blank_matches = conteúdo.scan(/___/)
    
    # Criar um blank para cada lacuna encontrada
    blank_matches.each_with_index do |_, index|
      blanks.create!(
        position: index + 1,
        correct_answer: "" # Será preenchido pelo professor
      )
    end
  end
  
  # Método para obter o texto com lacunas numeradas para exibição
  def text_with_numbered_blanks
    return conteúdo unless conteúdo.present?
    
    counter = 0
    conteúdo.gsub(/___/) do
      counter += 1
      "[#{counter}]"
    end
  end
  
  # Método para obter o texto com inputs para resolução
  def text_with_inputs(form_prefix = "fill_blank")
    return conteúdo unless conteúdo.present?
    
    counter = 0
    conteúdo.gsub(/___/) do
      counter += 1
      blank = blanks.find_by(position: counter)
      correct_answer = blank&.correct_answer || ""
      
      "<input type='text' name='#{form_prefix}_#{id}_blank_#{counter}' class='blank-input' data-blank-id='#{counter}' data-correct-answer='#{correct_answer}' placeholder='...' />"
    end.html_safe
  end
end
