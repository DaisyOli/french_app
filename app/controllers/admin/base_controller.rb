class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  private

  def ensure_admin!
    unless current_user.admin?
      redirect_to teacher_dashboard_path, alert: "Vous n'avez pas accès à cette page."
    end
  end

  def log_admin_action(action:, target_description:, details: nil)
    AdminAuditLog.create!(admin: current_user, action: action, target_description: target_description, details: details)
  end
end
