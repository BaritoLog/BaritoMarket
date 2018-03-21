Rails.application.routes.draw do
  devise_for :users, skip: :all

  resources :clients
  resources :forwarders
  resources :databags
  resources :stores
  resources :streams
  if EnabledFeatures.has?(:cas_integration)
    devise_scope :user do
      get "home/index", to: 'devise/cas_sessions#new', as: :new_user_session
      get "users/sign_out", to: 'devise/cas_sessions#destroy', as: :destroy_user_session
      get "users/service", to: 'devise/cas_sessions#service', as: :user_service
    end
    match 'profile/authenticate_cas', to: 'profile#authenticate_cas', via: :post, format: :json
  end

  root :controller => :home, :action => :index

  resources :home, :only => [:index]

  namespace :admin do
    resources :index, :only => [:index]
  end
end
