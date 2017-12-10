Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    resources :users, only: [:index, :create]
  end
end
