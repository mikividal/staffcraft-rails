require 'sidekiq/web'

Rails.application.routes.draw do
  # Mount Sidekiq Web UI (solo en development por ahora)
  if Rails.env.development?
    mount Sidekiq::Web => '/sidekiq'
  end

  # StaffCraft routes
  resources :analyses, only: [:new, :create, :show]
  root "analyses#new"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
