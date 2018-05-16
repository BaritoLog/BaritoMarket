class Api::AppsController < Api::BaseController
  def index
    render json: @app.as_json(only: [:name, :cluster_name, :app_status, :setup_status]), status: :ok
  end
end