class ActivityProcessingJob < ApplicationJob
  queue_as :default
  
  # Timeout de 5 minutos para processamento
  discard_on ActiveJob::DeserializationError
  retry_on StandardError, wait: 5.seconds, attempts: 3
  
  def perform(activity_id, user_id)
    activity = Activity.find(activity_id)
    user = User.find(user_id)
    
    Rails.logger.info "Processando atividade #{activity_id} para usuário #{user_id}"
    
    # Processamento em lotes para evitar timeout
    process_in_batches(activity, user)
    
    # Notificar conclusão
    ActivityMailer.processing_complete(activity, user).deliver_now
    
  rescue StandardError => e
    Rails.logger.error "Erro no processamento da atividade #{activity_id}: #{e.message}"
    ActivityMailer.processing_failed(activity, user, e.message).deliver_now
    raise
  end
  
  private
  
  def process_in_batches(activity, user)
    # Processar questões em lotes de 5 para evitar timeout
    batch_size = 5
    
    activity.questions.in_batches(of: batch_size) do |batch|
      batch.each { |question| process_question(question, user) }
      sleep(0.1) # Pequena pausa entre lotes
    end
    
    activity.fill_blanks.in_batches(of: batch_size) do |batch|
      batch.each { |fill_blank| process_fill_blank(fill_blank, user) }
      sleep(0.1)
    end
    
    # Continuar para outros tipos de exercício...
  end
  
  def process_question(question, user)
    # Lógica de processamento individual
    Rails.logger.debug "Processando questão #{question.id}"
  end
  
  def process_fill_blank(fill_blank, user)
    # Lógica de processamento individual
    Rails.logger.debug "Processando fill_blank #{fill_blank.id}"
  end
end 