class AppsController < ApplicationController
  include Wisper::Publisher

  before_action :set_app, except: :create
  before_action except: :create do
    authorize @app
  end

  def create
    @app = BaritoApp.new(app_group_id: app_params[:app_group_id])
    authorize @app

    @app = BaritoApp.setup(app_params)
    if @app.persisted?
      broadcast(:app_count_changed)
      return redirect_to @app.app_group
    else
      flash[:messages] = @app.errors.full_messages
      return redirect_to @app.app_group
    end
  end

  def update
    authorize @app
    unless app_params[:max_tps].to_i <= @app.app_group.max_tps
      flash[:alert] = "Max TPS (#{app_params[:max_tps]} TPS) should less than App Group Capacity (#{@app.app_group.max_tps} TPS)"
      return redirect_to app_group_path(@app.app_group)
    end
    @app.update_attributes(app_params)
    redirect_to app_group_path(@app.app_group)
  end

  def destroy
    @app.destroy
    broadcast(:app_count_changed)
    broadcast(:app_destroyed)
    return redirect_to @app.app_group
  end

  def toggle_status
    statuses = BaritoApp.statuses
    @app.update_attributes(status: params[:toggle_status] == 'true' ? statuses[:active] : statuses[:inactive])

    redirect_to app_group_path(params[:app_group_id])
  end

  private
    def app_params
      params.require(:barito_app).permit(
        :app_group_id,
        :name,
        :topic_name,
        :max_tps,
      )
    end

    def set_app
      @app = BaritoApp.find(params[:id])
    end
end
