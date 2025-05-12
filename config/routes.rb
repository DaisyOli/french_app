Rails.application.routes.draw do
  devise_for :students
  devise_for :users
  
  resources :activities do
    member do
      delete :remove_video
      delete :remove_image
      delete :remove_texte
      get :solve
    end
    
    resources :statements, only: [:create, :update, :destroy]
    resources :questions, only: [:create, :update, :destroy] do
      resources :alternatives, only: [:create, :update, :destroy]
    end
    resources :suggestions, only: [:create, :update, :destroy]
  end

  # Defines the root path route ("/")
  root "activities#index"
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
