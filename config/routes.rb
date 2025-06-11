Rails.application.routes.draw do
  devise_for :students, controllers: { invitations: 'students/invitations' }
  devise_for :users
  
  # Rota específica para estudantes
  get '/student_dashboard', to: 'students#dashboard', as: :student_dashboard
  get '/student_activities', to: 'students#activities', as: :student_activities
  
  # Rota específica para professores
  get '/teacher_dashboard', to: 'users#index', as: :teacher_dashboard
  
  # Root path redirecionando para login do estudante
  root to: redirect('/students/sign_in')
  
  # Health check para monitoramento
  get '/health', to: 'health#show'
  
  resources :activities do
    member do
      delete :remove_video
      delete :remove_image
      delete :remove_texte
      get :solve
      post :save_result
    end
    
    # Rotas para avaliações de atividades
    resources :activity_ratings, only: [:create, :update], path: 'ratings' do
      collection do
        patch :update, action: :update_by_student
      end
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
    
    resources :fill_blanks, only: [:create, :update, :destroy] do
      member do
        patch :update_order
      end
      resources :blanks, only: [:update]
    end
    
    resources :sentence_orderings, only: [:create, :update, :destroy] do
      member do
        patch :update_order
      end
    end
    
    resources :paragraph_orderings, only: [:create, :update, :destroy] do
      member do
        patch :update_order
      end
      resources :paragraph_sentences, only: [:create, :update, :destroy]
    end
    
    resources :column_associations, only: [:create, :update, :destroy] do
      member do
        patch :update_order
      end
      resources :association_pairs, only: [:create, :update, :destroy]
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
