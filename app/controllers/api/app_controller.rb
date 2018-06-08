class Api::AppController < ApiController
  def profile
    render json: {
      name: @app.name,
      app_group: @app.app_group,
      tps_config: @app.tps_config,
      cluster_name: @app.cluster_name,
      consul_host: @app.consul_host,
      app_status: @app.app_status,
      updated_at: @app.updated_at.strftime(Figaro.env.timestamp_format),
      meta: {
        # TODO: we should store this somewhere
        service_names: {
          producer: 'barito-flow-producer',
          zookeeper: 'zookeeper',
          kafka: 'kafka',
          consumer: 'barito-flow-consumer',
          elasticsearch: 'elasticsearch',
          kibana: 'kibana',
        },
      },
    }
  end

  def increase_log_count
    @app.increase_log_count(params[:new_log_count])
    render json: {
      log_count: @app.log_count,
    }
  end

  def es_post; end
end
