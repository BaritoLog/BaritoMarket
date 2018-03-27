class BaseController < ApplicationController
  protect_from_forgery with: :exception
  before_action :store_user_location!, if: :storable_location?
  before_action :authenticate_user, :remove_irrelevant_devise_flash, :find_current_user

  def authenticate_user
    if EnabledFeatures.has?(:cas_integration)
      :authenticate_user!
    end
  end

  def find_current_user
    if EnabledFeatures.has?(:cas_integration)
      @current_user = current_user
    else
      @current_user = User.new({:email => "dummy@email"})
    end
  end


  def remove_irrelevant_devise_flash
    flash[:notice] = nil
    flash.delete(:alert) if flash[:alert] == "You need to sign in or sign up before continuing."
  end

  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User)
      root_path
    else
      stored_location_for(resource_or_scope) || signed_in_root_path(resource_or_scope)
    end
  end

  def respond_modal_with(*args, &blk)
    options = args.extract_options!
    options[:responder] = ModalResponder
    respond_with *args, options, &blk
  end

  def after_sign_out_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || super
  end

  private
  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
