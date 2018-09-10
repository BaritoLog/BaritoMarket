class Api::AppsController < Api::BaseController
  include Wisper::Publisher
  skip_before_action :authenticate_token, :only => [:increase_log_count]

  def profile
    @app = BaritoApp.find_by_secret_key(params[:token])

    if @app.blank? || !@app.available?
      render json: {
        success: false,
        errors: ["App not found or inactive"],
        code: 404
      }, status: :not_found and return
    end

    @infrastructure = @app.app_group.infrastructure

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
          partition: TPS_CONFIG[@infrastructure.capacity]['kafka_options']['partition'],
          replication_factor: TPS_CONFIG[@infrastructure.capacity]['kafka_options']['replication_factor'],
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
    @app_groups = params[:application_groups]
    errors = []
    success_token = []
    unless @app_groups.empty? or @app_groups.blank?
      @app_groups.each do |metric|
        app_secret = (metric['token'].nil?) ? "" : metric['token']
        @app = BaritoApp.find_by_secret_key(app_secret)
        if @app.blank?
          errors << "#{app_secret} : is not a valid App Token"
          next
        end
        app_group = @app.app_group
        app_group.increase_log_count(metric[:new_log_count])
        @app.increase_log_count(metric[:new_log_count])
        @app.reload
        app_group.reload
        success_token << { token: metric[:token], log_count: @app.log_count }
        broadcast(:log_count_changed, @app.id, metric[:new_log_count])
      end
    end

    if not errors.empty?
      render json: {
          success: false,
          errors: errors,
          code: 404
      }, status: :not_found and return
    end

    render json: {
        data: success_token
    }, status: :ok
  end
end
