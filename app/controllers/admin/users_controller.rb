class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:update, :destroy]

  def update
    if @user.update(user_params)
      log_admin_action(action: "update_teacher_name", target_description: @user.email, details: "name -> #{@user.name}")
      redirect_to admin_root_path, notice: "Nom mis à jour."
    else
      redirect_to admin_root_path, alert: "Erreur lors de la mise à jour du nom."
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_root_path, alert: "Vous ne pouvez pas supprimer votre propre compte." and return
    end

    email = @user.email
    activities_count = @user.activities.count
    students_count = @user.students.count
    @user.destroy
    log_admin_action(
      action: "delete_teacher",
      target_description: email,
      details: "#{activities_count} activité(s) supprimée(s), #{students_count} étudiant(s) délié(s)"
    )
    redirect_to admin_root_path, notice: "Professeur supprimé."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name)
  end
end
