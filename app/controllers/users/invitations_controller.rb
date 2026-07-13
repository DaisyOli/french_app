class Users::InvitationsController < Devise::InvitationsController
  before_action :configure_permitted_parameters
  before_action :ensure_admin!, only: [:new, :create]

  skip_before_action :authenticate_inviter!, only: [:new, :create]
  skip_before_action :has_invitations_left?, only: [:new, :create]
  skip_before_action :resource_from_invitation_token, only: [:new, :create]

  # GET /users/invitation/new
  def new
    self.resource = resource_class.new
    render :new
  end

  # POST /users/invitation
  def create
    self.resource = resource_class.invite!(invite_params, current_user)

    if resource.errors.empty?
      redirect_to teacher_dashboard_path, notice: "Une invitation a été envoyée à #{resource.email}."
    else
      flash.now[:alert] = "Erreur lors de l'envoi de l'invitation : #{resource.errors.full_messages.join(', ')}"
      render :new
    end
  end

  # GET /users/invitation/accept?invitation_token=abcdef
  def edit
    super
  end

  # PUT /users/invitation
  def update
    super
  end

  protected

  # Só admin convida professor — professor comum nem chega perto desta tela.
  def ensure_admin!
    unless user_signed_in? && current_user.admin?
      redirect_to teacher_dashboard_path, alert: "Vous n'avez pas accès à cette page."
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: [:email])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [:password, :password_confirmation, :invitation_token])
  end

  def after_accept_path_for(resource)
    teacher_dashboard_path
  end

  def after_invite_path_for(current_inviter, invitee)
    teacher_dashboard_path
  end

  def invite_resource
    resource_class.invite!(invite_params, current_user)
  end

  private

  def invite_params
    devise_parameter_sanitizer.sanitize(:invite)
  end
end
