class Api::AppsController < Api::BaseController
  include Wisper::Publisher
  skip_before_action :authenticate_token, :only => [:increase_log_count]

  def profile
    if @app.blank?
      unless params[:app_name].present?
        render json: {
          success: false,
          errors: ["Params[:app_name] is required"],
          code: 404
        }, status: :not_found and return
      end
      @app = BaritoApp.find_by(
        name: params[:app_name],
        app_group_id: @app_group.id
      )
      if @app.blank?
        app_params = {
          app_group_id: @app_group.id,
          name: params[:app_name],
          topic_name: params[:app_name],
          max_tps: Figaro.env.default_app_tps
        }
        @app = BaritoApp.setup(app_params)
      end
    end

    unless @app.available?
      render json: {
        success: false,
        errors: ["App is inactive"],
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
    # Metrics are sent in batch
    app_group_metrics = metric_params[:application_groups]
    errors = []
    log_count_data = []

    if not app_group_metrics.blank?
      app_group_metrics.each do |app_metric|
        # Find app based on secret
        app_secret = app_metric[:token] || ""
        app = BaritoApp.find_by_secret_key(app_secret)
        if app.blank?
          errors << "#{app_secret} : is not a valid App Token"
          next
        end

        # Increase log count on both app_group and app
        app_group = app.app_group
        app_group.increase_log_count(app_metric[:new_log_count])
        app.increase_log_count(app_metric[:new_log_count])

        app.reload
        log_count_data << {
          token: app_metric[:token],
          log_count: app.log_count
        }

        broadcast(:log_count_changed,
          app.id,
          app_metric[:new_log_count]
        )
      end
    end

    if errors.empty? && !app_group_metrics.blank?
      render json: {
        data: log_count_data
      }, status: :ok
    else
      render json: {
        success: false,
        errors: errors,
        code: 404
      }, status: :not_found
    end
  end

  def metric_params
    params.permit({application_groups: [:token, :new_log_count]})
  end
end
