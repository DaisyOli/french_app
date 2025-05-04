class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  def index
    @activities = current_user.activities
  end

  def show
  end

  def new
    @activity = current_user.activities.new
  end

  def edit
  end

  def create
    @activity = current_user.activities.new(activity_params)

    if @activity.save
      redirect_to @activity, notice: 'Atividade criada com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @activity.update(activity_params)
      redirect_to @activity, notice: 'Atividade atualizada com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @activity.destroy
    redirect_to activities_path, notice: 'Atividade excluída com sucesso.'
  end

  private
    def set_activity
      @activity = current_user.activities.find(params[:id])
    end

    def activity_params
      params.require(:activity).permit(:título, :nível, :texto, :video_url, :imagem_url)
    end
end
