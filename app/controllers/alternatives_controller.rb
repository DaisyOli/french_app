class AlternativesController < ApplicationController
  before_action :set_activity
  before_action :set_question
  before_action :set_alternative, only: [:update, :destroy]

  def new
  end

  def create
    @alternative = @question.alternatives.new(alternative_params)
    
    respond_to do |format|
      if @alternative.save
        format.html { redirect_to activity_path(@activity, scroll_to: "question-#{@question.id}"), notice: t('flash.actions.create.notice', resource_name: Alternative.model_name.human) }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível adicionar a alternativa.' }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @alternative.update(alternative_params)
        format.html { redirect_to activity_path(@activity, scroll_to: "question-#{@question.id}"), notice: t('flash.actions.update.notice', resource_name: Alternative.model_name.human) }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível atualizar a alternativa.' }
      end
    end
  end

  def destroy
    @alternative.destroy
    respond_to do |format|
      format.html { redirect_to activity_path(@activity, scroll_to: "question-#{@question.id}"), notice: t('flash.actions.destroy.notice', resource_name: Alternative.model_name.human) }
    end
  end

  private
    def set_activity
      @activity = Activity.find(params[:activity_id])
    end

    def set_question
      @question = @activity.questions.find(params[:question_id])
    end

    def set_alternative
      @alternative = @question.alternatives.find(params[:id])
    end

    def alternative_params
      params.require(:alternative).permit(:conteúdo, :correta)
    end
end
