class QuestionsController < ApplicationController
  include ActivityOwnable

  before_action :set_question, only: [:update, :destroy]

  def new
  end

  def create
    @question = @activity.questions.new(question_params)
    @question.display_order = @activity.next_display_order

    respond_to do |format|
      if @question.save
        format.html { redirect_to activity_path(@activity, scroll_to: "question-#{@question.id}"), notice: t('flash.actions.create.notice', resource_name: Question.model_name.human) }
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
        format.html { redirect_to activity_path(@activity, scroll_to: "question-#{@question.id}"), notice: t('flash.actions.update.notice', resource_name: Question.model_name.human) }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível atualizar a questão.' }
      end
    end
  end

  def destroy
    ordem_removido = @question.display_order
    scroll_target = @activity.previous_element_dom_id(ordem_removido, exclude: @question)

    @question.destroy

    respond_to do |format|
      if scroll_target
        format.html { redirect_to activity_path(@activity, scroll_to: scroll_target),
                                  notice: t('flash.actions.destroy.notice', resource_name: Question.model_name.human) }
      else
        format.html { redirect_to activity_path(@activity), notice: t('flash.actions.destroy.notice', resource_name: Question.model_name.human) }
      end
    end
  end

  def update_order
    @question = @activity.questions.find(params[:id])

    if @question.update(display_order: params[:display_order])
      redirect_to activity_path(@activity, scroll_to: "question-#{@question.id}"), notice: t('flash.actions.update.notice', resource_name: Question.model_name.human)
    else
      redirect_to activity_path(@activity), alert: 'Erro ao atualizar ordem.'
    end
  end

  private
    def set_question
      @question = @activity.questions.find(params[:id])
    end

    def question_params
      params.require(:question).permit(:conteúdo, :tipo)
    end
end
