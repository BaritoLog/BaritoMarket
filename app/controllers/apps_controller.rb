class AppsController < ApplicationController
  include Wisper::Publisher
  def create
    @app = BaritoApp.setup(app_params)
    if @app.persisted?
      broadcast(:app_count_changed)
      return redirect_to @app.app_group
    else
      flash[:messages] = @app.errors.full_messages
      return redirect_to @app.app_group
    end
  end

  def destroy
    @app = BaritoApp.find(params[:id])
    broadcast(:app_count_changed)
    @app.destroy
    return redirect_to @app.app_group
  end

  private
    def app_params
      params.require(:barito_app).permit(
        :app_group_id, 
        :name, 
        :topic_name, 
        :max_tps
      )
    end
end
