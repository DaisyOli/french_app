class AssociationPairsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @column_association = ColumnAssociation.find(params[:column_association_id])
    @association_pair = @column_association.association_pairs.build(association_pair_params)
    
    if @association_pair.save
      redirect_to activity_path(@column_association.activity, scroll_to: "column-association-#{@column_association.id}"), notice: 'Paire d\'association ajoutée avec succès.'
    else
      redirect_to @column_association.activity, alert: 'Erreur lors de l\'ajout de la paire d\'association.'
    end
  end
  
  def update
    @association_pair = AssociationPair.find(params[:id])
    
    if @association_pair.update(association_pair_params)
      redirect_to activity_path(@association_pair.column_association.activity, scroll_to: "column-association-#{@association_pair.column_association.id}"), notice: 'Paire d\'association mise à jour avec succès.'
    else
      redirect_to @association_pair.column_association.activity, alert: 'Erreur lors de la mise à jour de la paire.'
    end
  end
  
  def destroy
    @association_pair = AssociationPair.find(params[:id])
    @column_association = @association_pair.column_association
    @activity = @column_association.activity
    @association_pair.destroy
    
    # Se ainda há pares na associação, redirecionar para a associação
    if @column_association.association_pairs.any?
      redirect_to activity_path(@activity, scroll_to: "column-association-#{@column_association.id}"), notice: 'Paire d\'association supprimée avec succès.'
    else
      # Se não há mais pares, redirecionar para a associação mesmo assim
      redirect_to activity_path(@activity, scroll_to: "column-association-#{@column_association.id}"), notice: 'Paire d\'association supprimée avec succès.'
    end
  end
  
  private
  
  def association_pair_params
    params.require(:association_pair).permit(:item_a, :item_b, :pair_order)
  end
end 