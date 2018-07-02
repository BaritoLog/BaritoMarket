class ApplicationController < ActionController::Base
  include Pundit

  before_action :authenticate_user!

  def ping
    render plain: 'ok', status: :ok
  end
end
