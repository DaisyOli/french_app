class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    # Página inicial dos professores - redireciona para atividades
    redirect_to activities_path
  end
end 