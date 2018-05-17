class Api::AppsController < Api::BaseController
  def index
    render json: @app.as_json(only: [:id, :name, :consul]), status: :ok
  end
end