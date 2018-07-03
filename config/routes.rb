Rails.application.routes.draw do
  require 'sidekiq/web'

  get 'ping', to: 'application#ping'
  namespace :api do
    post :increase_log_count, 
      to: 'apps#increase_log_count', defaults: { format: :json }
    get :profile,
      to: 'apps#profile', defaults: { format: :json }
    get :profile_by_cluster_name, 
      to: 'infrastructures#profile_by_cluster_name', defaults: { format: :json }
  end

  resources :app_groups, 
    only: %i[index show new create], 
    defaults: { format: :html }
  resources :apps,
    only: %i[create destroy], 
    defaults: { format: :html }

  root to: 'app_groups#index', defaults: { format: :html }
end
