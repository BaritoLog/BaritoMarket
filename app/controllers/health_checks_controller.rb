class HealthChecksController < ApplicationController
  skip_before_action :authenticate_user!, only: :ping

  def ping
    render plain: 'ok', status: :ok
  end
end
