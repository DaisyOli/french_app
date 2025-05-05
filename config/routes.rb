Rails.application.routes.draw do
  devise_for :students
  devise_for :users
  
  resources :activities do
    member do
      delete 'remove_video'
      delete 'remove_image'
    end
    
    resources :statements, only: [:new, :create, :edit, :update, :destroy]
    resources :questions, only: [:new, :create, :edit, :update, :destroy] do
      resources :alternatives, only: [:new, :create, :edit, :update, :destroy]
    end
    resources :suggestions, only: [:new, :create, :edit, :update, :destroy]
  end

  # Defines the root path route ("/")
  root "activities#index"
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
