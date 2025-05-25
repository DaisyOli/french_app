class StudentsController < ApplicationController
  before_action :authenticate_student!

  def dashboard
    @activities = Activity.all.order(:título)
    
    # Dados de progresso do estudante
    @completed_activities = current_student.completed_activities.includes(:activity)
    @completed_count = @completed_activities.count
    
    # Calcular score médio de forma mais robusta
    if @completed_activities.any?
      avg = @completed_activities.where.not(percentage: nil).average(:percentage)
      @average_score = avg ? avg.round(1) : 0
    else
      @average_score = 0
    end
    
    # IDs das atividades já completadas
    @completed_activity_ids = @completed_activities.pluck(:activity_id)

    # Informações do troféu de assiduidade
    @current_trophy = current_student.current_trophy
    @next_trophy = current_student.next_trophy_info
    @current_streak = current_student.current_streak
    @motivational_message = current_student.motivational_message
  end

  def activities
    # Buscar todas as atividades
    all_activities = Activity.all.order(:título)
    
    # Dados de progresso do estudante
    @completed_activities = current_student.completed_activities.includes(:activity)
    @completed_count = @completed_activities.count
    
    # IDs das atividades completadas com score >= 90% (consideradas dominadas)
    mastered_activity_ids = @completed_activities.where('percentage >= ?', 90).pluck(:activity_id)
    
    # Filtrar atividades: mostrar apenas as não feitas ou com score < 90%
    @activities = all_activities.where.not(id: mastered_activity_ids)
    
    # IDs das atividades já completadas (para mostrar indicador de conclusão)
    @completed_activity_ids = @completed_activities.pluck(:activity_id)
  end
end 