class QuestionsController < ApplicationController
  before_action :set_activity
  before_action :set_question, only: [:update, :destroy]

  def new
  end

  def create
    @question = @activity.questions.new(question_params)
    
    # Encontrar a maior ordem entre todos os elementos
    max_orders = []
    max_orders << @activity.video_order if @activity.video_url.present?
    max_orders << @activity.imagem_order if @activity.imagem_url.present?
    max_orders << @activity.texte_order if @activity.texte.present?
    max_orders << @activity.statements.maximum(:display_order) || 0
    max_orders << @activity.questions.maximum(:display_order) || 0
    max_orders << @activity.suggestions.maximum(:display_order) || 0
    
    @question.display_order = (max_orders.compact.max || 0) + 1
    
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

  def update_order
    @activity = Activity.find(params[:activity_id])
    @question = Question.find(params[:id])
    
    if @question.update(display_order: params[:display_order])
      redirect_to activity_path(@activity), notice: 'Ordem atualizada com sucesso.'
    else
      redirect_to activity_path(@activity), alert: 'Erro ao atualizar ordem.'
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
