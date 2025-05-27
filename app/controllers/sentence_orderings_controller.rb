class SentenceOrderingsController < ApplicationController
  before_action :set_activity
  before_action :set_sentence_ordering, only: [:update, :destroy]

  def create
    @sentence_ordering = @activity.sentence_orderings.new(sentence_ordering_params)
    
    # Encontrar a maior ordem entre todos os elementos
    max_orders = []
    max_orders << @activity.video_order if @activity.video_url.present?
    max_orders << @activity.imagem_order if @activity.imagem_url.present?
    max_orders << @activity.texte_order if @activity.texte.present?
    max_orders << @activity.statements.maximum(:display_order) || 0
    max_orders << @activity.questions.maximum(:display_order) || 0
    max_orders << @activity.suggestions.maximum(:display_order) || 0
    max_orders << @activity.fill_blanks.maximum(:display_order) || 0
    max_orders << @activity.sentence_orderings.maximum(:display_order) || 0
    max_orders << @activity.paragraph_orderings.maximum(:display_order) || 0
    
    @sentence_ordering.display_order = (max_orders.compact.max || 0) + 1
    
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
    # Salvar ordem do elemento que será removido
    ordem_removido = @sentence_ordering.display_order
    
    # Procurar elemento anterior ao removido (mesmo padrão dos outros controladores)
    elementos_anteriores = []
    
    # Verificar elementos de vídeo, imagem e texto
    elementos_anteriores << {type: 'video', id: 'video-section', order: @activity.video_order} if @activity.video_url.present? && @activity.video_order < ordem_removido
    elementos_anteriores << {type: 'image', id: 'image-section', order: @activity.imagem_order} if @activity.imagem_url.present? && @activity.imagem_order < ordem_removido
    elementos_anteriores << {type: 'texte', id: 'texte-section', order: @activity.texte_order} if @activity.texte.present? && @activity.texte_order < ordem_removido
    
    # Verificar statements
    @activity.statements.where('display_order < ?', ordem_removido).each do |stmt|
      elementos_anteriores << {type: 'statement', id: "statement-#{stmt.id}", order: stmt.display_order}
    end
    
    # Verificar questions
    @activity.questions.where('display_order < ?', ordem_removido).each do |quest|
      elementos_anteriores << {type: 'question', id: "question-#{quest.id}", order: quest.display_order}
    end
    
    # Verificar suggestions
    @activity.suggestions.where('display_order < ?', ordem_removido).each do |sugg|
      elementos_anteriores << {type: 'suggestion', id: "suggestion-#{sugg.id}", order: sugg.display_order}
    end
    
    # Verificar fill_blanks
    @activity.fill_blanks.where('display_order < ?', ordem_removido).each do |fb|
      elementos_anteriores << {type: 'fill_blank', id: "fill-blank-#{fb.id}", order: fb.display_order}
    end
    
    # Verificar outros sentence_orderings (exceto o que será removido)
    @activity.sentence_orderings.where('id != ? AND display_order < ?', @sentence_ordering.id, ordem_removido).each do |so|
      elementos_anteriores << {type: 'sentence_ordering', id: "sentence-ordering-#{so.id}", order: so.display_order}
    end
    
    # Verificar paragraph_orderings
    @activity.paragraph_orderings.where('display_order < ?', ordem_removido).each do |po|
      elementos_anteriores << {type: 'paragraph_ordering', id: "paragraph-ordering-#{po.id}", order: po.display_order}
    end
    
    # Destruir o exercício
    @sentence_ordering.destroy
    
    respond_to do |format|
      # Se houver elementos anteriores, redirecionar para o mais próximo
      if elementos_anteriores.any?
        # Ordenar elementos por ordem decrescente para encontrar o mais próximo
        elemento_anterior = elementos_anteriores.sort_by { |e| -e[:order] }.first
        format.html { redirect_to activity_path(@activity, scroll_to: elemento_anterior[:id]), 
                                  notice: 'Exercice d\'organisation de mots supprimé avec succès!' }
      else
        format.html { redirect_to activity_path(@activity), notice: 'Exercice d\'organisation de mots supprimé avec succès!' }
      end
    end
  end

  def update_order
    @activity = Activity.find(params[:activity_id])
    @sentence_ordering = SentenceOrdering.find(params[:id])
    
    if @sentence_ordering.update(display_order: params[:display_order])
      redirect_to activity_path(@activity, scroll_to: "sentence-ordering-#{@sentence_ordering.id}"), notice: 'Ordre mis à jour avec succès!'
    else
      redirect_to activity_path(@activity), alert: 'Erreur lors de la mise à jour de l\'ordre.'
    end
  end

  private
    def set_activity
      @activity = Activity.find(params[:activity_id])
    end

    def set_sentence_ordering
      @sentence_ordering = @activity.sentence_orderings.find(params[:id])
    end

    def sentence_ordering_params
      params.require(:sentence_ordering).permit(:conteúdo)
    end
end 