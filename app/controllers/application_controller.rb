class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  protect_from_forgery with: :exception
  
  # Security headers
  before_action :set_security_headers
  
  # Error handling for production
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::RoutingError, with: :routing_error
  
  protected
  
  def after_sign_in_path_for(resource)
    if resource.is_a?(Student)
      student_dashboard_path
    else
      teacher_dashboard_path
    end
  end
  
  # Helper para verificar se é um professor autenticado
  def teacher_signed_in?
    user_signed_in?
  end
  
  def current_teacher
    current_user
  end
  
  private
  
  def set_security_headers
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Referrer-Policy'] = 'strict-origin-when-cross-origin'
  end
  
  def record_not_found
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end
  
  def routing_error
    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end
end
