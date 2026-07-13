class Users::SessionsController < Devise::SessionsController
  private

  # "Connecté avec succès." / "Déconnecté avec succès." não agregam nada —
  # o próprio dashboard já mostra que a pessoa está logada. Suprime só o
  # flash automático do Devise, sem tocar nos outros alertas do app.
  def set_flash_message!(key, kind, options = {})
    nil
  end
end
