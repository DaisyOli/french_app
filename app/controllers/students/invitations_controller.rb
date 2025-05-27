class Students::InvitationsController < Devise::InvitationsController
  before_action :configure_permitted_parameters
  before_action :ensure_teacher_authenticated, only: [:new, :create]
  
  # Pular todas as autenticações padrão do Devise para new e create
  skip_before_action :authenticate_inviter!, only: [:new, :create]
  skip_before_action :has_invitations_left?, only: [:new, :create]
  skip_before_action :resource_from_invitation_token, only: [:new, :create]

  # GET /students/invitation/new
  def new
    # Esta view será vista pela professora - usar estética da Daisy
    self.resource = resource_class.new
    render :new
  end

  # POST /students/invitation
  def create
    # Apenas professores podem enviar convites
    self.resource = resource_class.invite!(invite_params, current_user)
    
    if resource.errors.empty?
      Rails.logger.info "Invitation sent successfully to: #{resource.email}"
      flash[:notice] = "Une invitation a été envoyée à #{resource.email} avec succès ! ✨"
      redirect_to activities_path
    else
      Rails.logger.error "Invitation failed with errors: #{resource.errors.full_messages}"
      flash[:alert] = "Erreur lors de l'envoi de l'invitation : #{resource.errors.full_messages.join(', ')}"
      render :new
    end
  end

  # GET /students/invitation/accept?invitation_token=abcdef
  def edit
    # Esta view será vista pelo estudante - usar estética do estudante
    super
  end

  # PUT /students/invitation
  def update
    # Estudante aceita o convite e define senha
    super
  end

  protected

  def ensure_teacher_authenticated
    unless user_signed_in?
      redirect_to new_user_session_path, alert: "Vous devez être connecté comme professeur pour inviter des étudiants."
      return false
    end
    
    true
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: [:email])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:password, :password_confirmation, :invitation_token])
  end

  def after_accept_path_for(resource)
    # Após aceitar convite, redirecionar para dashboard do estudante
    student_dashboard_path
  end

  def after_invite_path_for(current_inviter, invitee)
    # Após enviar convite, redirecionar para dashboard do professor
    activities_path
  end

  # Sobrescrever para definir quem está convidando
  def invite_resource
    resource_class.invite!(invite_params, current_user)
  end

  private

  def invite_params
    devise_parameter_sanitizer.sanitize(:invite)
  end
end 