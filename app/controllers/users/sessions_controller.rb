class Users::SessionsController < Devise::SessionsController
  private

  # "Connecté avec succès.", "Déconnecté avec succès.", "Vous êtes déjà
  # connecté." — nenhum agrega nada, o dashboard já mostra que a pessoa
  # está logada. set_flash_message! (login/logout) chama set_flash_message
  # por baixo, e require_no_authentication (a mensagem de "já conectado")
  # chama set_flash_message direto — sobrescrever só esta cobre as duas.
  def set_flash_message(key, kind, options = {})
    nil
  end
end
