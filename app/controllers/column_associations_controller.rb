class ColumnAssociationsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @activity = Activity.find(params[:activity_id])
    @column_association = @activity.column_associations.build(column_association_params)
    
    if @column_association.save
      redirect_to activity_path(@activity, scroll_to: "column-association-#{@column_association.id}"), notice: 'Exercice d\'association créé avec succès.'
    else
      redirect_to @activity, alert: 'Erreur lors de la création de l\'exercice d\'association.'
    end
  end
  
  def update
    @column_association = ColumnAssociation.find(params[:id])
    
    if @column_association.update(column_association_params)
      redirect_to activity_path(@column_association.activity, scroll_to: "column-association-#{@column_association.id}"), notice: 'Exercice d\'association mis à jour avec succès.'
    else
      redirect_to @column_association.activity, alert: 'Erreur lors de la mise à jour de l\'exercice.'
    end
  end
  
  def destroy
    @column_association = ColumnAssociation.find(params[:id])
    @activity = @column_association.activity
    
    # Coletar todos os elementos para encontrar o anterior, por que? Porque se não houver elementos anteriores, redirecionar para a atividade mesmo assim, da para refatorar para não ter que fazer isso?
    activity_elements = []
    
    activity_elements << {type: 'video', order: @activity.video_order || 1, id: 'video-section'} if @activity.video_url.present?
    activity_elements << {type: 'image', order: @activity.imagem_order || 2, id: 'image-section'} if @activity.imagem_url.present?
    activity_elements << {type: 'texte', order: @activity.texte_order || 3, id: 'texte-section'} if @activity.texte.present?
    
    @activity.statements.each do |statement|
      activity_elements << {type: 'statement', order: statement.display_order || statement.id, id: "statement-#{statement.id}"}
    end
    
    @activity.questions.each do |question|
      activity_elements << {type: 'question', order: question.display_order || question.id, id: "question-#{question.id}"}
    end
    
    @activity.suggestions.each do |suggestion|
      activity_elements << {type: 'suggestion', order: suggestion.display_order || suggestion.id, id: "suggestion-#{suggestion.id}"}
    end
    
    @activity.fill_blanks.each do |fill_blank|
      activity_elements << {type: 'fill_blank', order: fill_blank.display_order || fill_blank.id, id: "fill-blank-#{fill_blank.id}"}
    end
    
    @activity.sentence_orderings.each do |sentence_ordering|
      activity_elements << {type: 'sentence_ordering', order: sentence_ordering.display_order || sentence_ordering.id, id: "sentence-ordering-#{sentence_ordering.id}"}
    end
    
    @activity.paragraph_orderings.each do |paragraph_ordering|
      activity_elements << {type: 'paragraph_ordering', order: paragraph_ordering.display_order || paragraph_ordering.id, id: "paragraph-ordering-#{paragraph_ordering.id}"}
    end
    
    @activity.column_associations.where.not(id: @column_association.id).each do |column_association|
      activity_elements << {type: 'column_association', order: column_association.display_order || column_association.id, id: "column-association-#{column_association.id}"}
    end
    
    # Encontrar elementos anteriores (com ordem menor)
    current_order = @column_association.display_order || @column_association.id
    elementos_anteriores = activity_elements.select { |e| e[:order] < current_order }
    
    @column_association.destroy
    
    respond_to do |format|
      # Se houver elementos anteriores, redirecionar para o mais próximo
      if elementos_anteriores.any?
        # Ordenar elementos por ordem decrescente para encontrar o mais próximo
        elemento_anterior = elementos_anteriores.sort_by { |e| -e[:order] }.first
        format.html { redirect_to activity_path(@activity, scroll_to: elemento_anterior[:id]), 
                                  notice: 'Exercice d\'association supprimé avec succès.' }
      else
        format.html { redirect_to @activity, notice: 'Exercice d\'association supprimé avec succès.' }
      end
    end
  end
  
  def update_order
    @column_association = ColumnAssociation.find(params[:id])
    @column_association.update(display_order: params[:display_order])
    redirect_to activity_path(@column_association.activity, scroll_to: "column-association-#{@column_association.id}")
  end
  
  private
  
  def column_association_params
    params.require(:column_association).permit(:title, :instruction, :column_a_title, :column_b_title, :display_order, :activity_id)
  end
end 