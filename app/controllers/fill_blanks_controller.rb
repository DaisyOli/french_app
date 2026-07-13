class FillBlanksController < ApplicationController
  include ActivityOwnable

  before_action :set_fill_blank, only: [:update, :destroy]

  def create
    @fill_blank = @activity.fill_blanks.new(fill_blank_params)
    @fill_blank.display_order = @activity.next_display_order

    respond_to do |format|
      if @fill_blank.save
        # Processar as lacunas automaticamente
        @fill_blank.process_blanks!
        format.html { redirect_to activity_path(@activity, scroll_to: "fill-blank-#{@fill_blank.id}"), notice: 'Exercice à trous créé avec succès !' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Impossible d\'ajouter l\'exercice à trous.' }
      end
    end
  end

  def update
    respond_to do |format|
      if @fill_blank.update(fill_blank_params)
        # Reprocessar as lacunas se o conteúdo mudou
        if fill_blank_params[:conteúdo].present?
          @fill_blank.process_blanks!
        end
        format.html { redirect_to activity_path(@activity, scroll_to: "fill-blank-#{@fill_blank.id}"), notice: 'Exercice à trous mis à jour avec succès !' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Impossible de mettre à jour l\'exercice à trous.' }
      end
    end
  end

  def destroy
    ordem_removido = @fill_blank.display_order
    scroll_target = @activity.previous_element_dom_id(ordem_removido, exclude: @fill_blank)

    @fill_blank.destroy

    respond_to do |format|
      if scroll_target
        format.html { redirect_to activity_path(@activity, scroll_to: scroll_target),
                                  notice: 'Exercice à trous supprimé avec succès !' }
      else
        format.html { redirect_to activity_path(@activity), notice: 'Exercice à trous supprimé avec succès !' }
      end
    end
  end

  def update_order
    @fill_blank = @activity.fill_blanks.find(params[:id])

    if @fill_blank.update(display_order: params[:display_order])
      redirect_to activity_path(@activity, scroll_to: "fill-blank-#{@fill_blank.id}"), notice: 'Ordre mis à jour avec succès !'
    else
      redirect_to activity_path(@activity), alert: 'Erreur lors de la mise à jour de l\'ordre.'
    end
  end

  private
    def set_fill_blank
      @fill_blank = @activity.fill_blanks.find(params[:id])
    end

    def fill_blank_params
      params.require(:fill_blank).permit(:conteúdo)
    end
end
