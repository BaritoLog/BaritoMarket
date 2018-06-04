Rails.application.routes.draw do
  require 'sidekiq/web'
  get 'ping', to: 'ping#show', defaults: { format: :json }
  get 'api/profile', to: 'api/app#profile', defaults: { format: :json }
  resources :apps, only: %i[index new create show], defaults: { format: :html }
  root to: 'apps#index', defaults: { format: :html }
end
