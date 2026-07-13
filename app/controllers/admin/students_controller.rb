class Admin::StudentsController < Admin::BaseController
  def destroy
    student = Student.find(params[:id])
    email = student.email
    student.destroy
    log_admin_action(action: "delete_student", target_description: email)
    redirect_to admin_root_path, notice: "Étudiant supprimé."
  end
end
