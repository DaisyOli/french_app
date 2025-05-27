class ActivitiesController < ApplicationController
  before_action :authenticate_user_or_student!, except: [:solve]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :remove_video, :remove_image, :remove_texte]
  before_action :set_activity, only: [:show, :edit, :update, :destroy, :remove_video, :remove_image, :remove_texte, :solve, :save_result]

  def index
    @activities = Activity.all
  end

  def show
  end

  def new
    @activity = Activity.new
  end

  def edit
  end

  def solve
    # Não requer autenticação, pois é para os alunos
    # Renderiza a view de resolução
    render :solve
  end

  def save_result
    # Endpoint para salvar resultados das atividades dos estudantes
    if student_signed_in?
      @completed_activity = current_student.completed_activities.build(completed_activity_params)
      @completed_activity.activity = @activity
      @completed_activity.completed_at = Time.current
      
      if @completed_activity.save
        render json: { 
          success: true, 
          message: 'Resultado salvo com sucesso!',
          data: {
            score: @completed_activity.score,
            total_questions: @completed_activity.total_questions,
            percentage: @completed_activity.percentage
          }
        }
      else
        Rails.logger.error "Failed to save completed activity: #{@completed_activity.errors.full_messages}"
        render json: { 
          success: false, 
          message: 'Erro ao salvar resultado',
          errors: @completed_activity.errors.full_messages 
        }, status: :unprocessable_entity
      end
    else
      render json: { 
        success: false, 
        message: 'Não autorizado' 
      }, status: :unauthorized
    end
  end

  def create
    @activity = Activity.new(activity_params)
    @activity.user = current_user if defined?(current_user)

    respond_to do |format|
      # Verificar se a atividade é muito grande (baseado na experiência do app de português)
      if activity_too_large?(@activity)
        # Processar de forma assíncrona para atividades grandes
        if @activity.save
          ActivityProcessingJob.perform_later(@activity.id, current_user.id)
          format.html { redirect_to activity_path(@activity), notice: 'Activité créée avec succès. Le traitement est en cours...' }
        else
          format.html { render :new }
        end
      else
        # Processamento síncrono para atividades pequenas
        if @activity.save
          format.html { redirect_to activity_path(@activity), notice: t('flash.actions.create.notice', resource_name: Activity.model_name.human) }
        else
          format.html { render :new }
        end
      end
    end
  end

  def update
    respond_to do |format|
      scroll_target = nil
      
      # Determinar para qual elemento rolar baseado no que foi atualizado
      if activity_params[:video_url].present? && @activity.video_url != activity_params[:video_url]
        scroll_target = "video-section"
      elsif activity_params[:imagem_url].present? && @activity.imagem_url != activity_params[:imagem_url]
        scroll_target = "image-section"
      elsif activity_params[:texte].present? && @activity.texte != activity_params[:texte]
        scroll_target = "texte-section"
      end
      
      # Processar atualizações de ordem para elementos relacionados
      update_related_orders if params[:statements] || params[:questions] || params[:suggestions]
      
      if @activity.update(activity_params)
        if scroll_target
          format.html { redirect_to activity_path(@activity, scroll_to: scroll_target), notice: t('flash.actions.update.notice', resource_name: Activity.model_name.human) }
        else
          format.html { redirect_to activity_path(@activity), notice: t('flash.actions.update.notice', resource_name: Activity.model_name.human) }
        end
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to activities_path, notice: t('flash.actions.destroy.notice', resource_name: Activity.model_name.human) }
    end
  end

  # Método para remover o vídeo da atividade
  def remove_video
    # Salvar ordem do elemento que será removido
    ordem_removido = @activity.video_order
    
    # Procurar elemento anterior ao removido
    elementos_anteriores = []
    
    # Verificar outros elementos principais
    elementos_anteriores << {type: 'image', id: 'image-section', order: @activity.imagem_order} if @activity.imagem_url.present? && @activity.imagem_order < ordem_removido
    elementos_anteriores << {type: 'texte', id: 'texte-section', order: @activity.texte_order} if @activity.texte.present? && @activity.texte_order < ordem_removido
    
    # Verificar statements
    @activity.statements.where('display_order < ?', ordem_removido).each do |stmt|
      elementos_anteriores << {type: 'statement', id: "statement-#{stmt.id}", order: stmt.display_order}
    end
    
    # Verificar questions
    @activity.questions.where('display_order < ?', ordem_removido).each do |quest|
      elementos_anteriores << {type: 'question', id: "question-#{quest.id}", order: quest.display_order}
    end
    
    # Verificar suggestions
    @activity.suggestions.where('display_order < ?', ordem_removido).each do |sugg|
      elementos_anteriores << {type: 'suggestion', id: "suggestion-#{sugg.id}", order: sugg.display_order}
    end
    
    # Remover o vídeo
    @activity.update(video_url: nil)
    
    respond_to do |format|
      # Se houver elementos anteriores, redirecionar para o mais próximo
      if elementos_anteriores.any?
        # Ordenar elementos por ordem decrescente para encontrar o mais próximo
        elemento_anterior = elementos_anteriores.sort_by { |e| -e[:order] }.first
        format.html { redirect_to activity_path(@activity, scroll_to: elemento_anterior[:id]), 
                               notice: t('flash.actions.remove.video') }
      else
        format.html { redirect_to activity_path(@activity), notice: t('flash.actions.remove.video') }
      end
    end
  end

  # Método para remover a imagem da atividade
  def remove_image
    # Salvar ordem do elemento que será removido
    ordem_removido = @activity.imagem_order
    
    # Procurar elemento anterior ao removido
    elementos_anteriores = []
    
    # Verificar outros elementos principais
    elementos_anteriores << {type: 'video', id: 'video-section', order: @activity.video_order} if @activity.video_url.present? && @activity.video_order < ordem_removido
    elementos_anteriores << {type: 'texte', id: 'texte-section', order: @activity.texte_order} if @activity.texte.present? && @activity.texte_order < ordem_removido
    
    # Verificar statements
    @activity.statements.where('display_order < ?', ordem_removido).each do |stmt|
      elementos_anteriores << {type: 'statement', id: "statement-#{stmt.id}", order: stmt.display_order}
    end
    
    # Verificar questions
    @activity.questions.where('display_order < ?', ordem_removido).each do |quest|
      elementos_anteriores << {type: 'question', id: "question-#{quest.id}", order: quest.display_order}
    end
    
    # Verificar suggestions
    @activity.suggestions.where('display_order < ?', ordem_removido).each do |sugg|
      elementos_anteriores << {type: 'suggestion', id: "suggestion-#{sugg.id}", order: sugg.display_order}
    end
    
    # Remover a imagem
    @activity.update(imagem_url: nil)
    
    respond_to do |format|
      # Se houver elementos anteriores, redirecionar para o mais próximo
      if elementos_anteriores.any?
        # Ordenar elementos por ordem decrescente para encontrar o mais próximo
        elemento_anterior = elementos_anteriores.sort_by { |e| -e[:order] }.first
        format.html { redirect_to activity_path(@activity, scroll_to: elemento_anterior[:id]), 
                               notice: t('flash.actions.remove.image') }
      else
        format.html { redirect_to activity_path(@activity), notice: t('flash.actions.remove.image') }
      end
    end
  end

  # Método para remover o texto da atividade
  def remove_texte
    # Salvar ordem do elemento que será removido
    ordem_removido = @activity.texte_order
    
    # Procurar elemento anterior ao removido
    elementos_anteriores = []
    
    # Verificar outros elementos principais
    elementos_anteriores << {type: 'video', id: 'video-section', order: @activity.video_order} if @activity.video_url.present? && @activity.video_order < ordem_removido
    elementos_anteriores << {type: 'image', id: 'image-section', order: @activity.imagem_order} if @activity.imagem_url.present? && @activity.imagem_order < ordem_removido
    
    # Verificar statements
    @activity.statements.where('display_order < ?', ordem_removido).each do |stmt|
      elementos_anteriores << {type: 'statement', id: "statement-#{stmt.id}", order: stmt.display_order}
    end
    
    # Verificar questions
    @activity.questions.where('display_order < ?', ordem_removido).each do |quest|
      elementos_anteriores << {type: 'question', id: "question-#{quest.id}", order: quest.display_order}
    end
    
    # Verificar suggestions
    @activity.suggestions.where('display_order < ?', ordem_removido).each do |sugg|
      elementos_anteriores << {type: 'suggestion', id: "suggestion-#{sugg.id}", order: sugg.display_order}
    end
    
    # Remover o texto
    @activity.update(texte: nil)
    
    respond_to do |format|
      # Se houver elementos anteriores, redirecionar para o mais próximo
      if elementos_anteriores.any?
        # Ordenar elementos por ordem decrescente para encontrar o mais próximo
        elemento_anterior = elementos_anteriores.sort_by { |e| -e[:order] }.first
        format.html { redirect_to activity_path(@activity, scroll_to: elemento_anterior[:id]), 
                               notice: t('flash.actions.remove.texte') }
      else
        format.html { redirect_to activity_path(@activity), notice: t('flash.actions.remove.texte') }
      end
    end
  end

  private
    def set_activity
      @activity = Activity.find(params[:id])
    end

    def activity_params
      params.require(:activity).permit(:título, :nível, :texto, :video_url, :imagem_url, :texte, :video_order, :imagem_order, :texte_order)
    end

    def completed_activity_params
      params.require(:completed_activity).permit(:score, :total_questions)
    end

    def update_related_orders
      # Atualizar ordem dos statements
      if params[:statements]
        params[:statements].each do |statement_id, statement_params|
          statement = @activity.statements.find_by(id: statement_id)
          statement.update(display_order: statement_params[:display_order]) if statement
        end
      end
      
      # Atualizar ordem das questions
      if params[:questions]
        params[:questions].each do |question_id, question_params|
          question = @activity.questions.find_by(id: question_id)
          question.update(display_order: question_params[:display_order]) if question
        end
      end
      
      # Atualizar ordem das suggestions
      if params[:suggestions]
        params[:suggestions].each do |suggestion_id, suggestion_params|
          suggestion = @activity.suggestions.find_by(id: suggestion_id)
          suggestion.update(display_order: suggestion_params[:display_order]) if suggestion
        end
      end
    end

    def authenticate_user_or_student!
      unless user_signed_in? || student_signed_in?
        # Redirecionar para a página de login apropriada baseada no contexto
        if request.path.include?('student') || params[:student_context]
          redirect_to new_student_session_path, alert: t('devise.failure.unauthenticated')
        else
          redirect_to new_user_session_path, alert: t('devise.failure.unauthenticated')
        end
      end
    end
    
    # Método para verificar se a atividade é muito grande (baseado na experiência do app de português)
    def activity_too_large?(activity)
      # Estimar o número total de elementos que serão processados
      estimated_questions = activity.questions.count + 
                           activity.fill_blanks.sum { |fb| fb.blanks.count } +
                           activity.sentence_orderings.count +
                           activity.paragraph_orderings.sum { |po| po.paragraph_sentences.count } +
                           activity.column_associations.sum { |ca| ca.association_pairs.count }
      
      # Considerar atividade grande se tiver mais de 20 questões
      estimated_questions > 20
    end
end
