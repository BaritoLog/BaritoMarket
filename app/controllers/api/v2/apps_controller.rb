class Api::V2::AppsController < Api::V2::BaseController
  include Wisper::Publisher

  def profile
    valid, error_response = validate_required_keys([:app_secret])
    render json: error_response, status: error_response[:code] and return unless valid

    profile_response_json = REDIS_CACHE.get(
      "#{APP_PROFILE_CACHE_PREFIX}:#{params[:app_secret]}")
    if profile_response_json.present?
      render json: JSON.parse(profile_response_json) and return
    end

    # Try to fetch it from database if cache is missing
    app = BaritoApp.find_by(secret_key: params[:app_secret])

    if app.blank? || !app.available?
      render json: {
        success: false,
        errors: ["App not found or inactive"],
        code: 404
      }, status: :not_found and return
    end

    profile_response = generate_profile_response(app)
    broadcast(:profile_response_updated,
      params[:app_secret], profile_response)

    render json: profile_response
  end

  def profile_by_app_group
    valid, error_response = validate_required_keys(
      [:app_group_secret, :app_name])
    render json: error_response, status: error_response[:code] and return unless valid

    profile_response_json = REDIS_CACHE.get(
      "#{APP_GROUP_PROFILE_CACHE_PREFIX}:#{params[:app_group_secret]}:#{params[:app_name]}")
    if profile_response_json.present?
      render json: JSON.parse(profile_response_json) and return
    end

    # Fetch App Group
    app_group = AppGroup.find_by(secret_key: params[:app_group_secret])

    if app_group.blank? || !app_group.available?
      render json: {
        success: false,
        errors: ["AppGroup not found or inactive"],
        code: 404
      }, status: :not_found and return
    end

    # Fetch App
    app = BaritoApp.find_by(
      name: params[:app_name],
      app_group_id: app_group.id
    )

    if app.blank?
      app = BaritoApp.setup({
        app_group_id: app_group.id,
        name: params[:app_name],
        topic_name: params[:app_name],
        max_tps: Figaro.env.default_app_max_tps
      })
    elsif !app.available?
      render json: {
        success: false,
        errors: ["App is inactive"],
        code: 503
      }, status: :service_unavailable and return
    end

    profile_response = generate_profile_response(app)
    broadcast(:app_group_profile_response_updated,
      params[:app_group_secret], params[:app_name], profile_response)

    render json: profile_response
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
          errors << "#{app_secret} : is not a valid App Secret"
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

  private

  def metric_params
    params.permit({application_groups: [:token, :new_log_count]})
  end

  def generate_profile_response(app)
    infrastructure = app.app_group.infrastructure

    {
      id: app.id,
      name: app.name,
      app_secret: app.secret_key,
      app_group_name: app.app_group_name,
      max_tps: app.max_tps,
      cluster_name: app.cluster_name,
      consul_host: app.consul_host,
      status: app.status,
      updated_at: app.updated_at.strftime(Figaro.env.timestamp_format),
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
          topic_name: app.topic_name,
          partition: infrastructure.options['partition'],
          replication_factor: infrastructure.options['replication_factor'],
          consumer_group: 'barito',
        },
        elasticsearch: {
          index_prefix: app.topic_name,
          document_type: 'barito',
        },
      },
    }
  end

  def validate_required_keys(required_keys = [])
    valid = false
    error_response = {}

    required_keys.each do |key|
      valid = params.key?(key.to_sym) && !params[key.to_sym].blank?
      unless valid
        error_response = build_errors(422,
        ["Invalid Params: #{key} is a required parameter"])
        break
      end
    end

    [valid, error_response]
  end
end
