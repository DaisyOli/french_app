class SuggestionsController < ApplicationController
  before_action :set_activity
  before_action :set_suggestion, only: [:edit, :update, :destroy]

  def new
    @suggestion = @activity.suggestions.new
    render partial: 'form', locals: { suggestion: @suggestion }
  end

  def create
    @suggestion = @activity.suggestions.new(suggestion_params)
    
    # Encontrar a maior ordem entre todos os elementos
    max_orders = []
    max_orders << @activity.video_order if @activity.video_url.present?
    max_orders << @activity.imagem_order if @activity.imagem_url.present?
    max_orders << @activity.texte_order if @activity.texte.present?
    max_orders << @activity.statements.maximum(:display_order) || 0
    max_orders << @activity.questions.maximum(:display_order) || 0
    max_orders << @activity.suggestions.maximum(:display_order) || 0
    
    @suggestion.display_order = (max_orders.compact.max || 0) + 1
    
    respond_to do |format|
      if @suggestion.save
        format.html { redirect_to activity_path(@activity, scroll_to: "suggestion-#{@suggestion.id}"), notice: 'Sugestão foi adicionada com sucesso.' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível adicionar a sugestão.' }
      end
    end
  end

  def edit
    render partial: 'form', locals: { suggestion: @suggestion }
  end

  def update
    respond_to do |format|
      if @suggestion.update(suggestion_params)
        format.html { redirect_to activity_path(@activity, scroll_to: "suggestion-#{@suggestion.id}"), notice: 'Sugestão foi atualizada com sucesso.' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível atualizar a sugestão.' }
      end
    end
  end

  def destroy
    @suggestion.destroy
    respond_to do |format|
      format.html { redirect_to activity_path(@activity), notice: 'Sugestão foi removida com sucesso.' }
    end
  end

  def update_order
    @activity = Activity.find(params[:activity_id])
    @suggestion = Suggestion.find(params[:id])
    
    if @suggestion.update(display_order: params[:display_order])
      redirect_to activity_path(@activity), notice: 'Ordem atualizada com sucesso.'
    else
      redirect_to activity_path(@activity), alert: 'Erro ao atualizar ordem.'
    end
  end

  private

  def set_activity
    @activity = Activity.find(params[:activity_id])
  end

  def set_suggestion
    @suggestion = @activity.suggestions.find(params[:id])
  end

  def suggestion_params
    params.require(:suggestion).permit(:conteúdo)
  end
end
