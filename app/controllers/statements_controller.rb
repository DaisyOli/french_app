class StatementsController < ApplicationController
  before_action :set_activity
  before_action :set_statement, only: [:edit, :update, :destroy]

  def new
    @statement = @activity.statements.new
    render partial: 'form', locals: { statement: @statement }
  end

  def create
    @statement = @activity.statements.new(statement_params)
    
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
