class AssociationPairsController < ApplicationController
  include ActivityOwnable

  before_action :set_column_association

  def create
    @association_pair = @column_association.association_pairs.build(association_pair_params)
    
    if @association_pair.save
      redirect_to activity_path(@column_association.activity, scroll_to: "column-association-#{@column_association.id}"), notice: 'Paire d\'association ajoutée avec succès.'
    else
      redirect_to @column_association.activity, alert: 'Erreur lors de l\'ajout de la paire d\'association.'
    end
  end
  
  def update
    @association_pair = @column_association.association_pairs.find(params[:id])

    if @association_pair.update(association_pair_params)
      redirect_to activity_path(@activity, scroll_to: "column-association-#{@column_association.id}"), notice: 'Paire d\'association mise à jour avec succès.'
    else
      redirect_to @activity, alert: 'Erreur lors de la mise à jour de la paire.'
    end
  end

  def destroy
    @association_pair = @column_association.association_pairs.find(params[:id])
    @association_pair.destroy

    redirect_to activity_path(@activity, scroll_to: "column-association-#{@column_association.id}"), notice: 'Paire d\'association supprimée avec succès.'
  end

  private

  def set_column_association
    @column_association = @activity.column_associations.find(params[:column_association_id])
  end

  def association_pair_params
    params.require(:association_pair).permit(:item_a, :item_b, :pair_order)
  end
end 