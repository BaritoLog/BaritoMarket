Rails.application.routes.draw do
  require 'sidekiq/web'
  get 'ping', to: 'application#ping'
  namespace :api do
    post :increase_log_count, to: 'app#increase_log_count', defaults: { format: :json }
    get :profile, to: 'app#profile', defaults: { format: :json }
    post :es_post, to: 'app#es_post', defaults: { format: :json }
  end
  resources :apps, only: %i[index new create show], defaults: { format: :html }
  root to: 'apps#index', defaults: { format: :html }
end
