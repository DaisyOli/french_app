class StatementsController < ApplicationController
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
        format.html { redirect_to activity_path(@activity, scroll_to: "statement-#{@statement.id}"), notice: 'Enunciado foi adicionado com sucesso.' }
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
        format.html { redirect_to activity_path(@activity, scroll_to: "statement-#{@statement.id}"), notice: 'Enunciado foi atualizado com sucesso.' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível atualizar o enunciado.' }
      end
    end
  end

  def destroy
    @statement.destroy
    respond_to do |format|
      format.html { redirect_to activity_path(@activity), notice: 'Enunciado foi removido com sucesso.' }
    end
  end

  def update_order
    @activity = Activity.find(params[:activity_id])
    @statement = Statement.find(params[:id])
    
    if @statement.update(display_order: params[:display_order])
      redirect_to activity_path(@activity), notice: 'Ordem atualizada com sucesso.'
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
