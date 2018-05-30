Rails.application.routes.draw do
  require 'sidekiq/web'
  get 'ping', to: 'ping#show', defaults: { format: :json }
  resources :app, only: %i[index new create show], defaults: { format: :html }
  root to: 'app#index', defaults: { format: :html }
end
