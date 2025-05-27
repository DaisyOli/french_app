class ActivityMailer < ApplicationMailer
  default from: 'noreply@frenchapp.com'

  def processing_complete(activity, user)
    @activity = activity
    @user = user
    @url = activity_url(@activity)
    
    mail(
      to: @user.email,
      subject: "Votre activité '#{@activity.título}' a été traitée avec succès"
    )
  end

  def processing_failed(activity, user, error_message)
    @activity = activity
    @user = user
    @error_message = error_message
    @url = activity_url(@activity)
    
    mail(
      to: @user.email,
      subject: "Erreur lors du traitement de votre activité '#{@activity.título}'"
    )
  end
end 