class PingController < ApplicationController
  def show
    render text: 'ok', status: :ok
  end
end
