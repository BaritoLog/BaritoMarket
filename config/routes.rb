Rails.application.routes.draw do
  devise_for :users
  require 'sidekiq/web'

  get 'ping', to: 'health_checks#ping'

  namespace :api do
    post :increase_log_count,
      to: 'apps#increase_log_count',
      defaults: { format: :json }
    get :profile,
      to: 'apps#profile',
      defaults: { format: :json }
    get :profile_by_cluster_name, 
      to: 'infrastructures#profile_by_cluster_name',
      defaults: { format: :json }
  end

  get '/users/search', to: 'users#search', defaults: { format: :json }
  get '/groups/search', to: 'groups#search', defaults: { format: :json }

  resources :app_group_admins,
    only: %i[create destroy]
  resources :app_group_permissions,
    only: %i[show create destroy]
  resources :app_groups,
    only: %i[index show new create],
    defaults: { format: :html } do
      collection do
        get :search
      end
    end
  resources :apps,
    only: %i[create destroy],
    defaults: { format: :html }
  resources :groups,
    except: %i[edit update],
    defaults: { format: :html }
  resources :group_users,
    only: %i[create destroy],
    defaults: { format: :html }

  root to: 'app_groups#index', defaults: { format: :html }
end
