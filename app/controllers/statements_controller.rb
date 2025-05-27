class StatementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_activity
  before_action :set_statement, only: [:edit, :update, :destroy]

  def new
    @statement = @activity.statements.new
    render partial: 'form', locals: { statement: @statement }
  end

  def create
    @statement = @activity.statements.new(statement_params)
    
    # Encontrar a maior ordem entre todos os elementos
    max_orders = []
    max_orders << @activity.video_order if @activity.video_url.present?
    max_orders << @activity.imagem_order if @activity.imagem_url.present?
    max_orders << @activity.texte_order if @activity.texte.present?
    max_orders << @activity.statements.maximum(:display_order) || 0
    max_orders << @activity.questions.maximum(:display_order) || 0
    max_orders << @activity.suggestions.maximum(:display_order) || 0
    
    @statement.display_order = (max_orders.compact.max || 0) + 1
    
    respond_to do |format|
      if @statement.save
        format.html { redirect_to activity_path(@activity, scroll_to: "statement-#{@statement.id}"), notice: t('flash.actions.create.notice', resource_name: Statement.model_name.human) }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível adicionar o enunciado.' }
      end
    end
  end

  def edit
    render partial: 'form', locals: { statement: @statement }
  end

  def update
    respond_to do |format|
      if @statement.update(statement_params)
        format.html { redirect_to activity_path(@activity, scroll_to: "statement-#{@statement.id}"), notice: t('flash.actions.update.notice', resource_name: Statement.model_name.human) }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível atualizar o enunciado.' }
      end
    end
  end

  def destroy
    # Salvar ordem do elemento que será removido
    ordem_removido = @statement.display_order
    
    # Procurar elemento anterior ao removido (mesmo tipo ou outro tipo)
    elementos_anteriores = []
    
    # Verificar elementos de vídeo, imagem e texto
    elementos_anteriores << {type: 'video', id: 'video-section', order: @activity.video_order} if @activity.video_url.present? && @activity.video_order < ordem_removido
    elementos_anteriores << {type: 'image', id: 'image-section', order: @activity.imagem_order} if @activity.imagem_url.present? && @activity.imagem_order < ordem_removido
    elementos_anteriores << {type: 'texte', id: 'texte-section', order: @activity.texte_order} if @activity.texte.present? && @activity.texte_order < ordem_removido
    
    # Verificar statements
    @activity.statements.where('id != ? AND display_order < ?', @statement.id, ordem_removido).each do |stmt|
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
    
    # Destruir o statement
    @statement.destroy
    
    respond_to do |format|
      # Se houver elementos anteriores, redirecionar para o mais próximo
      if elementos_anteriores.any?
        # Ordenar elementos por ordem decrescente para encontrar o mais próximo
        elemento_anterior = elementos_anteriores.sort_by { |e| -e[:order] }.first
        format.html { redirect_to activity_path(@activity, scroll_to: elemento_anterior[:id]), 
                                  notice: t('flash.actions.destroy.notice', resource_name: Statement.model_name.human) }
      else
        format.html { redirect_to activity_path(@activity), notice: t('flash.actions.destroy.notice', resource_name: Statement.model_name.human) }
      end
    end
  end

  def update_order
    @activity = Activity.find(params[:activity_id])
    @statement = Statement.find(params[:id])
    
    if @statement.update(display_order: params[:display_order])
      redirect_to activity_path(@activity, scroll_to: "statement-#{@statement.id}"), notice: t('flash.actions.update.notice', resource_name: Statement.model_name.human)
    else
      redirect_to activity_path(@activity), alert: 'Erro ao atualizar ordem.'
    end
  end

  private

  def set_activity
    @activity = Activity.find(params[:activity_id])
  end

  def set_statement
    @statement = @activity.statements.find(params[:id])
  end

  def statement_params
    params.require(:statement).permit(:conteúdo)
  end

end
