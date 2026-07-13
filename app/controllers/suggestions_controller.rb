class SuggestionsController < ApplicationController
  include ActivityOwnable

  before_action :set_suggestion, only: [:update, :destroy]

  def create
    @suggestion = @activity.suggestions.new(suggestion_params)
    @suggestion.display_order = @activity.next_display_order

    respond_to do |format|
      if @suggestion.save
        format.html { redirect_to activity_path(@activity, scroll_to: "suggestion-#{@suggestion.id}"), notice: t('flash.actions.create.notice', resource_name: Suggestion.model_name.human) }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível adicionar a sugestão.' }
      end
    end
  end

  def update
    respond_to do |format|
      if @suggestion.update(suggestion_params)
        format.html { redirect_to activity_path(@activity, scroll_to: "suggestion-#{@suggestion.id}"), notice: t('flash.actions.update.notice', resource_name: Suggestion.model_name.human) }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível atualizar a sugestão.' }
      end
    end
  end

  def destroy
    ordem_removido = @suggestion.display_order
    scroll_target = @activity.previous_element_dom_id(ordem_removido, exclude: @suggestion)

    @suggestion.destroy

    respond_to do |format|
      if scroll_target
        format.html { redirect_to activity_path(@activity, scroll_to: scroll_target),
                                  notice: t('flash.actions.destroy.notice', resource_name: Suggestion.model_name.human) }
      else
        format.html { redirect_to activity_path(@activity), notice: t('flash.actions.destroy.notice', resource_name: Suggestion.model_name.human) }
      end
    end
  end

  def update_order
    @suggestion = @activity.suggestions.find(params[:id])

    if @suggestion.update(display_order: params[:display_order])
      redirect_to activity_path(@activity, scroll_to: "suggestion-#{@suggestion.id}"), notice: t('flash.actions.update.notice', resource_name: Suggestion.model_name.human)
    else
      redirect_to activity_path(@activity), alert: 'Erro ao atualizar ordem.'
    end
  end

  private

  def set_suggestion
    @suggestion = @activity.suggestions.find(params[:id])
  end

  def suggestion_params
    params.require(:suggestion).permit(:conteúdo)
  end
end
