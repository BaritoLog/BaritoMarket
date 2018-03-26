class Api::ClientsController < Api::BaseController
  def index
    render json: {:client => @client.as_json(only: :produce_url)}, status: :ok
  end
end