class Api::AppController < ApiController
  def profile
    render json: {
      name: @app.name,
      app_group: @app.app_group,
      tps_config: @app.tps_config,
      cluster_name: @app.cluster_name,
      app_status: @app.app_status,
      updated_at: @app.updated_at.strftime(Figaro.env.timestamp_format),
    }
  end

  def es_post; end
end
