Rails.application.routes.draw do
  devise_for :students
  devise_for :users
  
  # Rota específica para estudantes
  get '/student_dashboard', to: 'students#dashboard', as: :student_dashboard
  get '/student_activities', to: 'students#activities', as: :student_activities
  
  # Rota específica para professores
  get '/teacher_dashboard', to: 'users#index', as: :teacher_dashboard
  
  # Root path redirecionando para login do estudante
  root to: redirect('/students/sign_in')
  
  resources :activities do
    member do
      delete :remove_video
      delete :remove_image
      delete :remove_texte
      get :solve
      post :save_result
    end
    
    resources :statements, only: [:create, :update, :destroy] do
      member do
        patch :update_order
      end
    end
    
    resources :questions, only: [:create, :update, :destroy] do
      member do
        patch :update_order
      end
      resources :alternatives, only: [:create, :update, :destroy]
    end
    
    resources :suggestions, only: [:create, :update, :destroy] do
      member do
        patch :update_order
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
