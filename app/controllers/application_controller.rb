class ApplicationController < ActionController::Base
  
  protected
  
  def after_sign_in_path_for(resource)
    if resource.is_a?(Student)
      student_dashboard_path
    else
      teacher_dashboard_path
    end
  end
end
