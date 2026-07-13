class SentenceOrderingsController < ApplicationController
  include ActivityOwnable

  before_action :set_sentence_ordering, only: [:update, :destroy]

  def create
    @sentence_ordering = @activity.sentence_orderings.new(sentence_ordering_params)
    @sentence_ordering.display_order = @activity.next_display_order

    respond_to do |format|
      if @sentence_ordering.save
        # Processar as palavras automaticamente
        @sentence_ordering.process_words!
        format.html { redirect_to activity_path(@activity, scroll_to: "sentence-ordering-#{@sentence_ordering.id}"), notice: 'Exercice d\'organisation de mots créé avec succès!' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Impossible d\'ajouter l\'exercice d\'organisation de mots.' }
      end
    end
  end

  def update
    respond_to do |format|
      if @sentence_ordering.update(sentence_ordering_params)
        # Reprocessar as palavras se o conteúdo mudou
        if sentence_ordering_params[:conteúdo].present?
          @sentence_ordering.process_words!
        end
        format.html { redirect_to activity_path(@activity, scroll_to: "sentence-ordering-#{@sentence_ordering.id}"), notice: 'Exercice d\'organisation de mots mis à jour avec succès!' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Impossible de mettre à jour l\'exercice d\'organisation de mots.' }
      end
    end
  end

  def destroy
    ordem_removido = @sentence_ordering.display_order
    scroll_target = @activity.previous_element_dom_id(ordem_removido, exclude: @sentence_ordering)

    @sentence_ordering.destroy

    respond_to do |format|
      if scroll_target
        format.html { redirect_to activity_path(@activity, scroll_to: scroll_target),
                                  notice: 'Exercice d\'organisation de mots supprimé avec succès!' }
      else
        format.html { redirect_to activity_path(@activity), notice: 'Exercice d\'organisation de mots supprimé avec succès!' }
      end
    end
  end

  def update_order
    @sentence_ordering = @activity.sentence_orderings.find(params[:id])

    if @sentence_ordering.update(display_order: params[:display_order])
      redirect_to activity_path(@activity, scroll_to: "sentence-ordering-#{@sentence_ordering.id}"), notice: 'Ordre mis à jour avec succès!'
    else
      redirect_to activity_path(@activity), alert: 'Erreur lors de la mise à jour de l\'ordre.'
    end
  end

  private
    def set_sentence_ordering
      @sentence_ordering = @activity.sentence_orderings.find(params[:id])
    end

    def sentence_ordering_params
      params.require(:sentence_ordering).permit(:conteúdo)
    end
end 