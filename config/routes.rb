Rails.application.routes.draw do
  resources :log_templates
  devise_for :users, skip: :all

  if EnabledFeatures.has?(:cas_integration)
    devise_scope :user do
      authenticated :user do
        root 'home#index', as: :authenticated_root
        resources :clients
        resources :forwarders
        resources :databags
        resources :stores
        resources :streams
        resources :user_groups
      end

      unauthenticated do
        root 'devise/cas_sessions#new', as: :unauthenticated_root
      end

      get "users/sign_out", to: 'devise/cas_sessions#destroy', as: :destroy_user_session
      get "users/service", to: 'devise/cas_sessions#service', as: :user_service
    end
    match 'profile/authenticate_cas', to: 'profile#authenticate_cas', via: :post, format: :json
  else
    root 'home#index'
    resources :clients
    resources :forwarders
    resources :databags
    resources :stores
    resources :streams
    resources :user_groups
  end

  # namespace :admin do
  #   resources :index, :only => [:index]
  # end

  namespace :api, defaults: { format: :json } do
    resources :clients, :only => [:index]
  end
end
