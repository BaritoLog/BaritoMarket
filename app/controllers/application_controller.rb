class ApplicationController < ActionController::Base
  def ping
    render plain: 'ok', status: :ok
  end
end
