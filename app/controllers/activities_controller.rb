class ActivitiesController < ApplicationController
  before_action :authenticate_user!, except: [:solve]
  before_action :set_activity, only: [:show, :edit, :update, :destroy, :remove_video, :remove_image, :remove_texte, :solve]

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

  def create
    @activity = Activity.new(activity_params)
    @activity.user = current_user if defined?(current_user)

    respond_to do |format|
      if @activity.save
        format.html { redirect_to activity_path(@activity), notice: 'Atividade foi criada com sucesso.' }
      else
        format.html { render :new }
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
          format.html { redirect_to activity_path(@activity, scroll_to: scroll_target), notice: 'Atividade foi atualizada com sucesso.' }
        else
          format.html { redirect_to activity_path(@activity), notice: 'Atividade foi atualizada com sucesso.' }
        end
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to activities_path, notice: 'Atividade foi apagada com sucesso.' }
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
                               notice: 'Vídeo foi removido com sucesso.' }
      else
        format.html { redirect_to activity_path(@activity), notice: 'Vídeo foi removido com sucesso.' }
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
                               notice: 'Imagem foi removida com sucesso.' }
      else
        format.html { redirect_to activity_path(@activity), notice: 'Imagem foi removida com sucesso.' }
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
                               notice: 'Texto foi removido com sucesso.' }
      else
        format.html { redirect_to activity_path(@activity), notice: 'Texto foi removido com sucesso.' }
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
end
