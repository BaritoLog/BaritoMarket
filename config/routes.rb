Rails.application.routes.draw do
  require 'sidekiq/web'

  devise_for :users

  get 'ping', to: 'health_checks#ping'

  namespace :api do
    # DEPRECATED
    # These v1 APIs are in the process of being removed
    # Use v2 APIs instead
    post :increase_log_count,
      to: 'apps#increase_log_count',
      defaults: { format: :json }
    get :profile,
      to: 'apps#profile',
      defaults: { format: :json }
    get :profile_by_app_group,
      to: 'apps#profile_by_app_group',
      defaults: { format: :json }
    # get :profile_by_cluster_name,
    #   to: 'infrastructures#profile_by_cluster_name',
    #   defaults: { format: :json }
    get :authorize,
      to: 'infrastructures#authorize_by_username',
      defaults: { format: :json }
    get :profile_curator,
      to: 'infrastructures#profile_curator',
      defaults: { format: :json }

    namespace :v2 do
      post :increase_log_count,
        to: 'apps#increase_log_count',
        defaults: { format: :json }
      get :profile,
        to: 'apps#profile',
        defaults: { format: :json }
      get :profile_by_app_group,
        to: 'apps#profile_by_app_group',
        defaults: { format: :json }
      get :profile_by_cluster_name,
        to: 'infrastructures#profile_by_cluster_name',
        defaults: { format: :json }
      get :authorize,
        to: 'infrastructures#authorize_by_username',
        defaults: { format: :json }
      get :profile_curator,
        to: 'infrastructures#profile_curator',
        defaults: { format: :json }
    end
  end

  get '/users/search', to: 'users#search', defaults: { format: :json }
  get '/groups/search', to: 'groups#search', defaults: { format: :json }
  match '/app_group_users/:user_id/set_role/:role_id', to: 'app_group_users#set_role', via: [:put, :patch], as: 'set_role_app_group_user'
  delete '/app_group_users/:user_id/delete/:app_group_id', to: 'app_group_users#destroy', as: 'app_group_user'
  match '/apps/:app_group_id/toggle_status/:id', to: 'apps#toggle_status', via: [:put, :patch], as: 'toggle_status_app'

  resources :app_group_users,
    only: %i[create update],
    defaults: { format: :html }
  resources :app_groups,
    only: %i[index show new create update],
    defaults: { format: :html } do
      member do
        get :manage_access
      end
      collection do
        get :search
      end
    end
  resources :apps,
    only: %i[create destroy update],
    defaults: { format: :html }
  resources :ext_apps,
    defaults: { format: :html } do
      member do
        post :regenerate_token
      end
    end
  resources :groups,
    except: %i[edit update],
    defaults: { format: :html }
  resources :group_users,
    only: %i[create destroy],
    defaults: { format: :html }
  resources :infrastructures,
    only: %i[show],
    defaults: { format: :html } do
      member do
        post :retry_provision
        post :provisioning_check
        post :retry_bootstrap
        patch :toggle_status
        delete :delete
      end
    end
  resources :infrastructure_components,
    only: %i[edit update],
    defaults: { format: :html }
  resources :cluster_templates,
    defaults: { format: :html }
  resources :component_templates,
    defaults: { format: :html }

  root to: 'app_groups#index', defaults: { format: :html }
end
