class ActivitiesController < ApplicationController
  before_action :authenticate_user!, except: [:solve]
  before_action :set_activity, only: [:show, :edit, :update, :destroy, :remove_video, :remove_image, :remove_texte, :solve]

  def index
    @activities = Activity.all
  end

  def show
  end

  def new
    @activity = Activity.new
  end

  def edit
  end

  def solve
    # Não requer autenticação, pois é para os alunos
    # Renderiza a view de resolução
    render :solve
  end

  def create
    @activity = Activity.new(activity_params)
    @activity.user = current_user if defined?(current_user)

    respond_to do |format|
      if @activity.save
        format.html { redirect_to activity_path(@activity), notice: 'Atividade foi criada com sucesso.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      scroll_target = nil
      
      # Determinar para qual elemento rolar baseado no que foi atualizado
      if activity_params[:video_url].present? && @activity.video_url != activity_params[:video_url]
        scroll_target = "video-section"
      elsif activity_params[:imagem_url].present? && @activity.imagem_url != activity_params[:imagem_url]
        scroll_target = "image-section"
      elsif activity_params[:texte].present? && @activity.texte != activity_params[:texte]
        scroll_target = "texte-section"
      end
      
      if @activity.update(activity_params)
        redirect_params = { notice: 'Atividade foi atualizada com sucesso.' }
        redirect_params[:scroll_to] = scroll_target if scroll_target
        
        format.html { redirect_to activity_path(@activity, redirect_params) }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to activities_path, notice: 'Atividade foi apagada com sucesso.' }
    end
  end

  # Método para remover o vídeo da atividade
  def remove_video
    @activity.update(video_url: nil)
    respond_to do |format|
      format.html { redirect_to activity_path(@activity), notice: 'Vídeo foi removido com sucesso.' }
    end
  end

  # Método para remover a imagem da atividade
  def remove_image
    @activity.update(imagem_url: nil)
    respond_to do |format|
      format.html { redirect_to activity_path(@activity), notice: 'Imagem foi removida com sucesso.' }
    end
  end

  # Método para remover o texto da atividade
  def remove_texte
    @activity.update(texte: nil)
    respond_to do |format|
      format.html { redirect_to activity_path(@activity), notice: 'Texto foi removido com sucesso.' }
    end
  end

  private
    def set_activity
      @activity = Activity.find(params[:id])
    end

    def activity_params
      params.require(:activity).permit(:título, :nível, :texto, :video_url, :imagem_url, :texte)
    end
end
