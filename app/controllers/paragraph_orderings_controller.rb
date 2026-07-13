class ParagraphOrderingsController < ApplicationController
  include ActivityOwnable

  before_action :set_paragraph_ordering, only: [:update, :destroy]

  def create
    @paragraph_ordering = @activity.paragraph_orderings.new(paragraph_ordering_params)
    @paragraph_ordering.display_order = @activity.next_display_order

    respond_to do |format|
      if @paragraph_ordering.save
        format.html { redirect_to activity_path(@activity, scroll_to: "paragraph-ordering-#{@paragraph_ordering.id}"), notice: 'Exercice d\'organisation de phrases créé avec succès!' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Impossible d\'ajouter l\'exercice d\'organisation de phrases.' }
      end
    end
  end

  def update
    respond_to do |format|
      if @paragraph_ordering.update(paragraph_ordering_params)
        format.html { redirect_to activity_path(@activity, scroll_to: "paragraph-ordering-#{@paragraph_ordering.id}"), notice: 'Exercice d\'organisation de phrases mis à jour avec succès!' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Impossible de mettre à jour l\'exercice d\'organisation de phrases.' }
      end
    end
  end

  def destroy
    ordem_removido = @paragraph_ordering.display_order
    scroll_target = @activity.previous_element_dom_id(ordem_removido, exclude: @paragraph_ordering)

    @paragraph_ordering.destroy

    respond_to do |format|
      if scroll_target
        format.html { redirect_to activity_path(@activity, scroll_to: scroll_target),
                                  notice: 'Exercice d\'organisation de phrases supprimé avec succès!' }
      else
        format.html { redirect_to activity_path(@activity), notice: 'Exercice d\'organisation de phrases supprimé avec succès!' }
      end
    end
  end

  def update_order
    @paragraph_ordering = @activity.paragraph_orderings.find(params[:id])

    if @paragraph_ordering.update(display_order: params[:display_order])
      redirect_to activity_path(@activity, scroll_to: "paragraph-ordering-#{@paragraph_ordering.id}"), notice: 'Ordre mis à jour avec succès!'
    else
      redirect_to activity_path(@activity), alert: 'Erreur lors de la mise à jour de l\'ordre.'
    end
  end

  private
    def set_paragraph_ordering
      @paragraph_ordering = @activity.paragraph_orderings.find(params[:id])
    end

    def paragraph_ordering_params
      params.require(:paragraph_ordering).permit(:titre, :instruction)
    end
end 