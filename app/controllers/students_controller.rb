class StudentsController < ApplicationController
  before_action :authenticate_student!

  def dashboard
    # Dados de progresso do estudante
    @completed_activities = current_student.completed_activities.order(created_at: :desc)
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

    # Próxima atividade recomendada pro card "Continuer" — só dentro do que o
    # aluno pode acessar (nível dele e abaixo; sem nível definido = tudo)
    level_order = ApplicationHelper::CEFR_COLORS.keys
    accessible_levels = current_student.accessible_levels
    @next_activity = Activity.where(nível: accessible_levels)
                              .where.not(id: @completed_activity_ids)
                              .sort_by { |a| [level_order.index(a.nível) || 99, a.título] }
                              .first
    @next_activity_is_retry = @next_activity.nil?
    @next_completed_record = @next_activity_is_retry ? @completed_activities.first : nil
    @next_activity ||= @next_completed_record&.activity

    # Progresso por nível CEFR pra grade de níveis (níveis fora do alcance do
    # aluno aparecem marcados como bloqueados, não escondidos)
    level_totals = Activity.group(:nível).count
    level_completed = current_student.completed_activities.joins(:activity).group('activities.nível').count
    @level_progress = level_order.map do |level|
      total = level_totals[level] || 0
      completed = level_completed[level] || 0
      { level: level, total: total, completed: completed,
        pct: total.zero? ? 0 : (completed * 100.0 / total).round,
        locked: !accessible_levels.include?(level) }
    end

    # Progresso por compétence (CO/CE/EE) pro card "Votre progression" —
    # mesmo cálculo do progresso por nível acima, só agrupando por outra
    # coluna. Atividades sem compétence definida (ainda não classificadas
    # pela professora) não entram em nenhum dos 3 totais.
    comp_totals = Activity.group(:competência).count
    comp_completed = current_student.completed_activities.joins(:activity).group('activities.competência').count
    @competencia_progress = %w[CO CE EE].map do |code|
      total = comp_totals[code] || 0
      completed = comp_completed[code] || 0
      { competencia: code, total: total, completed: completed,
        pct: total.zero? ? 0 : (completed * 100.0 / total).round }
    end

    # Nível pro badge celebratório: o nível atribuído ao aluno; sem isso,
    # cai pro nível mais alto onde ele já completou alguma atividade.
    @badge_level = current_student.nível.presence ||
                   @level_progress.reverse.find { |lp| lp[:completed] > 0 }&.dig(:level) ||
                   accessible_levels.first
  end

  def activities
    # Buscar todas as atividades com avaliações pré-carregadas, só as que o
    # aluno pode acessar (nível dele e abaixo; sem nível definido = tudo)
    all_activities = Activity.includes(:activity_ratings, :questions, :fill_blanks,
                                        :sentence_orderings, :paragraph_orderings, :column_associations)
                              .where(nível: current_student.accessible_levels)
                              .order(:título)
    
    # Dados de progresso do estudante
    @completed_activities = current_student.completed_activities.includes(:activity)
    @completed_count = @completed_activities.count
    
    # IDs das atividades completadas com score >= 90% (consideradas dominadas)
    mastered_activity_ids = @completed_activities.where('percentage >= ?', 90).pluck(:activity_id)
    
    # Filtrar atividades: mostrar apenas as não feitas ou com score < 90%
    @activities = all_activities.where.not(id: mastered_activity_ids)
    
    # IDs das atividades já completadas (para mostrar indicador de conclusão)
    @completed_activity_ids = @completed_activities.pluck(:activity_id)
    
    # Pré-carregar avaliações do estudante atual para evitar N+1 queries
    activity_ids = @activities.pluck(:id)
    @student_ratings = current_student.activity_ratings
                                     .where(activity_id: activity_ids)
                                     .index_by(&:activity_id)
  end
end 