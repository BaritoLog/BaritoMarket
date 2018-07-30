Rails.application.routes.draw do
  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'

  devise_for :users

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
  match '/app_group_users/:user_id/set_role', to: 'app_group_users#set_role', via: [:put, :patch], as: 'set_role_app_group_user'
  delete '/app_group_users/:user_id/delete/:app_group_id', to: 'app_group_users#destroy', as: 'app_group_user'

  resources :app_group_users,
    only: %i[create update],
    defaults: { format: :html }
  resources :app_groups,
    only: %i[index show new create],
    defaults: { format: :html } do
      member do
        get :manage_access
      end
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
  resources :infrastructures,
    only: %i[index show],
    defaults: { format: :html } do
      member do
        post :retry
      end
    end

  root to: 'app_groups#index', defaults: { format: :html }
end
