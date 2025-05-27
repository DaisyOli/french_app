class FillBlanksController < ApplicationController
  before_action :set_activity
  before_action :set_fill_blank, only: [:update, :destroy]

  def create
    @fill_blank = @activity.fill_blanks.new(fill_blank_params)
    
    # Encontrar a maior ordem entre todos os elementos
    max_orders = []
    max_orders << @activity.video_order if @activity.video_url.present?
    max_orders << @activity.imagem_order if @activity.imagem_url.present?
    max_orders << @activity.texte_order if @activity.texte.present?
    max_orders << @activity.statements.maximum(:display_order) || 0
    max_orders << @activity.questions.maximum(:display_order) || 0
    max_orders << @activity.suggestions.maximum(:display_order) || 0
    max_orders << @activity.fill_blanks.maximum(:display_order) || 0
    
    @fill_blank.display_order = (max_orders.compact.max || 0) + 1
    
    respond_to do |format|
      if @fill_blank.save
        # Processar as lacunas automaticamente
        @fill_blank.process_blanks!
        format.html { redirect_to activity_path(@activity, scroll_to: "fill-blank-#{@fill_blank.id}"), notice: 'Exercício de lacunas criado com sucesso!' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível adicionar o exercício de lacunas.' }
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
        format.html { redirect_to activity_path(@activity, scroll_to: "fill-blank-#{@fill_blank.id}"), notice: 'Exercício de lacunas atualizado com sucesso!' }
      else
        format.html { redirect_to activity_path(@activity), alert: 'Não foi possível atualizar o exercício de lacunas.' }
      end
    end
  end

  def destroy
    # Salvar ordem do elemento que será removido
    ordem_removido = @fill_blank.display_order
    
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
    
    # Verificar outros fill_blanks (exceto o que será removido)
    @activity.fill_blanks.where('id != ? AND display_order < ?', @fill_blank.id, ordem_removido).each do |fb|
      elementos_anteriores << {type: 'fill_blank', id: "fill-blank-#{fb.id}", order: fb.display_order}
    end
    
    # Destruir o exercício de lacunas
    @fill_blank.destroy
    
    respond_to do |format|
      # Se houver elementos anteriores, redirecionar para o mais próximo
      if elementos_anteriores.any?
        # Ordenar elementos por ordem decrescente para encontrar o mais próximo
        elemento_anterior = elementos_anteriores.sort_by { |e| -e[:order] }.first
        format.html { redirect_to activity_path(@activity, scroll_to: elemento_anterior[:id]), 
                                  notice: 'Exercício de lacunas removido com sucesso!' }
      else
        format.html { redirect_to activity_path(@activity), notice: 'Exercício de lacunas removido com sucesso!' }
      end
    end
  end

  def update_order
    @activity = Activity.find(params[:activity_id])
    @fill_blank = FillBlank.find(params[:id])
    
    if @fill_blank.update(display_order: params[:display_order])
      redirect_to activity_path(@activity, scroll_to: "fill-blank-#{@fill_blank.id}"), notice: 'Ordem atualizada com sucesso!'
    else
      redirect_to activity_path(@activity), alert: 'Erro ao atualizar ordem.'
    end
  end

  private
    def set_activity
      @activity = Activity.find(params[:activity_id])
    end

    def set_fill_blank
      @fill_blank = @activity.fill_blanks.find(params[:id])
    end

    def fill_blank_params
      params.require(:fill_blank).permit(:conteúdo)
    end
end
