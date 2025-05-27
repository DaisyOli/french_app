class ParagraphOrderingsController < ApplicationController
  before_action :set_activity
  before_action :set_paragraph_ordering, only: [:update, :destroy]

  def create
    @paragraph_ordering = @activity.paragraph_orderings.new(paragraph_ordering_params)
    
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
    
    @paragraph_ordering.display_order = (max_orders.compact.max || 0) + 1
    
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
    # Salvar ordem do elemento que será removido
    ordem_removido = @paragraph_ordering.display_order
    
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
    
    # Verificar sentence_orderings
    @activity.sentence_orderings.where('display_order < ?', ordem_removido).each do |so|
      elementos_anteriores << {type: 'sentence_ordering', id: "sentence-ordering-#{so.id}", order: so.display_order}
    end
    
    # Verificar outros paragraph_orderings (exceto o que será removido)
    @activity.paragraph_orderings.where('id != ? AND display_order < ?', @paragraph_ordering.id, ordem_removido).each do |po|
      elementos_anteriores << {type: 'paragraph_ordering', id: "paragraph-ordering-#{po.id}", order: po.display_order}
    end
    
    # Destruir o exercício
    @paragraph_ordering.destroy
    
    respond_to do |format|
      # Se houver elementos anteriores, redirecionar para o mais próximo
      if elementos_anteriores.any?
        # Ordenar elementos por ordem decrescente para encontrar o mais próximo
        elemento_anterior = elementos_anteriores.sort_by { |e| -e[:order] }.first
        format.html { redirect_to activity_path(@activity, scroll_to: elemento_anterior[:id]), 
                                  notice: 'Exercice d\'organisation de phrases supprimé avec succès!' }
      else
        format.html { redirect_to activity_path(@activity), notice: 'Exercice d\'organisation de phrases supprimé avec succès!' }
      end
    end
  end

  def update_order
    @activity = Activity.find(params[:activity_id])
    @paragraph_ordering = ParagraphOrdering.find(params[:id])
    
    if @paragraph_ordering.update(display_order: params[:display_order])
      redirect_to activity_path(@activity, scroll_to: "paragraph-ordering-#{@paragraph_ordering.id}"), notice: 'Ordre mis à jour avec succès!'
    else
      redirect_to activity_path(@activity), alert: 'Erreur lors de la mise à jour de l\'ordre.'
    end
  end

  private
    def set_activity
      @activity = Activity.find(params[:activity_id])
    end

    def set_paragraph_ordering
      @paragraph_ordering = @activity.paragraph_orderings.find(params[:id])
    end

    def paragraph_ordering_params
      params.require(:paragraph_ordering).permit(:titre, :instruction)
    end
end 