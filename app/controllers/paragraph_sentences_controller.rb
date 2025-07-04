class ParagraphSentencesController < ApplicationController
  before_action :set_activity
  before_action :set_paragraph_ordering
  before_action :set_paragraph_sentence, only: [:update, :destroy]

  def create
    @paragraph_sentence = @paragraph_ordering.paragraph_sentences.new(paragraph_sentence_params)
    
    # Definir posições automaticamente
    max_position = @paragraph_ordering.paragraph_sentences.maximum(:correct_position) || 0
    @paragraph_sentence.correct_position = max_position + 1
    @paragraph_sentence.display_position = max_position + 1
    
    respond_to do |format|
      if @paragraph_sentence.save
        format.html { redirect_to activity_path(@activity, scroll_to: "paragraph-ordering-#{@paragraph_ordering.id}"), notice: 'Phrase ajoutée avec succès!' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Impossible d\'ajouter la phrase.' }
      end
    end
  end

  def update
    respond_to do |format|
      if @paragraph_sentence.update(paragraph_sentence_params)
        format.html { redirect_to activity_path(@activity, scroll_to: "paragraph-ordering-#{@paragraph_ordering.id}"), notice: 'Phrase mise à jour avec succès!' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Impossible de mettre à jour la phrase.' }
      end
    end
  end

  def destroy
    @paragraph_sentence.destroy
    
    respond_to do |format|
      format.html { redirect_to activity_path(@activity, scroll_to: "paragraph-ordering-#{@paragraph_ordering.id}"), notice: 'Phrase supprimée avec succès!' }
    end
  end

  private
    def set_activity
      @activity = Activity.find_by_param(params[:activity_id])
    end

    def set_paragraph_ordering
      @paragraph_ordering = @activity.paragraph_orderings.find(params[:paragraph_ordering_id])
    end

    def set_paragraph_sentence
      @paragraph_sentence = @paragraph_ordering.paragraph_sentences.find(params[:id])
    end

    def paragraph_sentence_params
      params.require(:paragraph_sentence).permit(:sentence)
    end
end 