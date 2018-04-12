class HomeController < BaseController
  def index
    redirect_to :controller => 'apps', :action => 'index'
  end
end
