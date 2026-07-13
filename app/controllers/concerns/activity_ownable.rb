# Todo controller que mexe em exercício de uma atividade (statements,
# questions, fill_blanks, etc.) inclui este concern: exige login E confere
# que a atividade (params[:activity_id], sempre o primeiro nível da rota
# aninhada) pertence ao professor logado. Sem isso, qualquer professor —
# ou, em alguns controllers, qualquer visitante — editava exercício de
# atividade alheia só sabendo o link.
module ActivityOwnable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_owned_activity
  end

  private

  def set_owned_activity
    @activity = Activity.find_by_param(params[:activity_id])
    return if @activity.user == current_user

    redirect_to activities_path, alert: "Vous n'avez pas accès à cette activité."
  end
end
