class ApplicationController < ActionController::Base
  include Pundit

  before_action :authenticate_user!
end
