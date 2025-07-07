Rails.application.routes.draw do
    devise_for :users, skip: :all
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
   # root to: "home#index"

   namespace :api do
    namespace :v1 do
      # Authentication
      post '/auth/login', to: 'auth#login'
      post '/auth/register', to: 'auth#register'
      get '/auth/me', to: 'auth#me'

      # Core resources
      resources :analyses, only: [:index, :show, :create, :destroy]
      resources :users, only: [:show, :update]
    end
  end

    # WebSocket
  mount ActionCable.server => '/cable'

  # Sidekiq Web UI (in development)
  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
