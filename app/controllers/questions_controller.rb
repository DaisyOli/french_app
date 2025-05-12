class QuestionsController < ApplicationController
  before_action :set_activity
  before_action :set_question, only: [:update, :destroy]

  def new
  end

  def create
    @question = @activity.questions.new(question_params)
    
    respond_to do |format|
      if @question.save
        format.html { redirect_to activity_path(@activity, scroll_to: "question-#{@question.id}"), notice: 'Questão foi adicionada com sucesso.' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível adicionar a questão.' }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to activity_path(@activity, scroll_to: "question-#{@question.id}"), notice: 'Questão foi atualizada com sucesso.' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível atualizar a questão.' }
      end
    end
  end

  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to activity_path(@activity), notice: 'Questão foi removida com sucesso.' }
    end
  end

  private
    def set_activity
      @activity = Activity.find(params[:activity_id])
    end

    def set_question
      @question = @activity.questions.find(params[:id])
    end

    def question_params
      params.require(:question).permit(:conteúdo, :tipo)
    end
end
