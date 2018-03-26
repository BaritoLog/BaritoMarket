class BaseController < ApplicationController
# Prevent CSRF attacks by raising an exception.
# For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user, :remove_irrelevant_devise_flash, :find_current_user
  #

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
end
