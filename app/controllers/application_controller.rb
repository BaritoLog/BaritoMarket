class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def ping
    render plain: 'ok', status: :ok
  end
end
