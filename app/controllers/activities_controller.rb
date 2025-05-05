class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_activity, only: [:show, :edit, :update, :destroy, :remove_video, :remove_image]

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

  # Método para remover o vídeo da atividade
  def remove_video
    @activity.update(video_url: nil)
    redirect_to @activity, notice: t('flash.actions.remove.video')
  end

  # Método para remover a imagem da atividade
  def remove_image
    @activity.update(imagem_url: nil)
    redirect_to @activity, notice: t('flash.actions.remove.image')
  end

  private
    def set_activity
      @activity = current_user.activities.find(params[:id])
    end

    def activity_params
      params.require(:activity).permit(:título, :nível, :texto, :texte, :video_url, :imagem_url)
    end
end
