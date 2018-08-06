class Api::AppsController < ApiController
  def profile
    @app = BaritoApp.find_by_secret_key(params[:token])
    render json: {
      id: @app.id,
      name: @app.name,
      app_group_name: @app.app_group_name,
      max_tps: @app.max_tps,
      cluster_name: @app.cluster_name,
      consul_host: @app.consul_host,
      status: @app.status,
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
        kafka: {
          topic_name: @app.topic_name,
          # TODO: should revised with values that are stored in DB
          partition: 1,
          replication_factor: 1,
          consumer_group: 'barito',
        },
        elasticsearch: {
          index_prefix: @app.topic_name,
          document_type: 'barito',
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
end
