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
    if app_params[:max_tps].to_i > @app.app_group.max_tps
      flash[:alert] = "Max TPS (#{app_params[:max_tps]} TPS) should be less than AppGroup capacity (#{@app.app_group.max_tps} TPS)"
      return redirect_to app_group_path(@app.app_group)
    elsif @app.app_group.new_total_tps(app_params[:max_tps].to_i - @app.max_tps) > @app.app_group.max_tps
      flash[:alert] = "With this new max TPS (#{app_params[:max_tps]} TPS), new AppGroup total TPS (#{@app.app_group.new_total_tps(app_params[:max_tps].to_i - @app.max_tps)} TPS)  will exceed AppGroup capacity"
      return redirect_to app_group_path(@app.app_group)
    end
    @app.update_attributes(app_params)
    broadcast(:app_updated, @app.app_group.secret_key, @app.secret_key, @app.name)
    redirect_to app_group_path(@app.app_group)
  end

  def update_log_retention_days
    @app.update(params.require(:barito_app).permit(:log_retention_days))
    redirect_to app_group_path(@app.app_group)
  end

  def destroy
    secret_key = @app.secret_key
    app_group_secret_key = @app.app_group.secret_key
    app_name = @app.name
    @app.destroy
    broadcast(:app_count_changed)
    broadcast(:app_destroyed, app_group_secret_key, secret_key, app_name)
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
