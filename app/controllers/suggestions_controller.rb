class SuggestionsController < ApplicationController
  before_action :set_activity
  before_action :set_suggestion, only: [:edit, :update, :destroy]

  def new
    @suggestion = @activity.suggestions.new
    render partial: 'form', locals: { suggestion: @suggestion }
  end

  def create
    @suggestion = @activity.suggestions.new(suggestion_params)
    
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
