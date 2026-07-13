class StatementsController < ApplicationController
  include ActivityOwnable

  before_action :set_statement, only: [:update, :destroy]

  def create
    @statement = @activity.statements.new(statement_params)
    @statement.display_order = @activity.next_display_order

    respond_to do |format|
      if @statement.save
        format.html { redirect_to activity_path(@activity, scroll_to: "statement-#{@statement.id}"), notice: t('flash.actions.create.notice', resource_name: Statement.model_name.human) }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível adicionar o enunciado.' }
      end
    end
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
    ordem_removido = @statement.display_order
    scroll_target = @activity.previous_element_dom_id(ordem_removido, exclude: @statement)

    @statement.destroy

    respond_to do |format|
      if scroll_target
        format.html { redirect_to activity_path(@activity, scroll_to: scroll_target),
                                  notice: t('flash.actions.destroy.notice', resource_name: Statement.model_name.human) }
      else
        format.html { redirect_to activity_path(@activity), notice: t('flash.actions.destroy.notice', resource_name: Statement.model_name.human) }
      end
    end
  end

  def update_order
    @statement = @activity.statements.find(params[:id])

    if @statement.update(display_order: params[:display_order])
      redirect_to activity_path(@activity, scroll_to: "statement-#{@statement.id}"), notice: t('flash.actions.update.notice', resource_name: Statement.model_name.human)
    else
      redirect_to activity_path(@activity), alert: 'Erro ao atualizar ordem.'
    end
  end

  private

  def set_statement
    @statement = @activity.statements.find(params[:id])
  end

  def statement_params
    params.require(:statement).permit(:conteúdo)
  end

end
