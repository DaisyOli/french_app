class ColumnAssociationsController < ApplicationController
  include ActivityOwnable

  def create
    @column_association = @activity.column_associations.build(column_association_params)
    
    if @column_association.save
      redirect_to activity_path(@activity, scroll_to: "column-association-#{@column_association.id}"), notice: 'Exercice d\'association créé avec succès.'
    else
      redirect_to @activity, alert: 'Erreur lors de la création de l\'exercice d\'association.'
    end
  end
  
  def update
    @column_association = @activity.column_associations.find(params[:id])

    if @column_association.update(column_association_params)
      redirect_to activity_path(@column_association.activity, scroll_to: "column-association-#{@column_association.id}"), notice: 'Exercice d\'association mis à jour avec succès.'
    else
      redirect_to @column_association.activity, alert: 'Erreur lors de la mise à jour de l\'exercice.'
    end
  end

  def destroy
    @column_association = @activity.column_associations.find(params[:id])
    ordem_removido = @column_association.display_order || @column_association.id
    scroll_target = @activity.previous_element_dom_id(ordem_removido, exclude: @column_association)

    @column_association.destroy

    respond_to do |format|
      if scroll_target
        format.html { redirect_to activity_path(@activity, scroll_to: scroll_target),
                                  notice: 'Exercice d\'association supprimé avec succès.' }
      else
        format.html { redirect_to @activity, notice: 'Exercice d\'association supprimé avec succès.' }
      end
    end
  end
  
  def update_order
    @column_association = @activity.column_associations.find(params[:id])
    @column_association.update(display_order: params[:display_order])
    redirect_to activity_path(@activity, scroll_to: "column-association-#{@column_association.id}")
  end
  
  private
  
  def column_association_params
    params.require(:column_association).permit(:title, :instruction, :column_a_title, :column_b_title, :display_order, :activity_id)
  end
end 