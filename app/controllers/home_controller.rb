class HomeController < BaseController
  def index
    unless @current_user.nil?
      @clients = Client.where(user_id: @current_user.id)
    else
      @clients = Client.all
    end
  end
end
