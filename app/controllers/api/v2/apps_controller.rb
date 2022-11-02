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
    render json: {
      data: []
    }, status: :ok
  end

  def update_barito_app
    valid, error_response = validate_required_keys(
      [:app_group_secret, :app_name])
    render json: error_response, status: error_response[:code] and return unless valid

    app_group = AppGroup.find_by(secret_key: params[:app_group_secret])
    if app_group.blank? || !app_group.available?
      render json: {
        success: false,
        errors: ['AppGroup not found or inactive'],
        code: 404
      }, status: :not_found and return
    end
    
    app = BaritoApp.find_by(
      app_group: app_group,
      name: params[:app_name]
    )
    if app.blank?
      app = BaritoApp.create(
        app_group_id: app_group.id,
        name: params[:app_name],
        topic_name: params[:app_name].gsub(/ /, '-'),
        secret_key: BaritoApp.generate_key,
        max_tps: params[:max_tps].to_i,
        log_retention_days: params[:log_retention_days].to_i,
        status: BaritoApp.statuses[:active],
      )
    elsif !app.available?
      render json: {
        success: false,
        errors: ["App is inactive"],
        code: 503
      }, status: :service_unavailable and return
    else
      app.update(
        max_tps: params[:max_tps],
        log_retention_days: params[:log_retention_days]
      )
    end

    app_response = generate_profile_response(app)
    broadcast(:profile_response_updated,
      app.secret_key, app_response)

    broadcast(:app_group_profile_response_updated,
      params[:app_group_secret], params[:app_name], app_response)

   render json: app_response
  end

  private

  def metric_params
    params.permit({application_groups: [:token, :new_log_count]})
  end

  def generate_profile_response(app)
    helm_infrastructure = app.app_group.helm_infrastructure
    environment = app.app_group&.environment
    replication_factor = environment == "production" ? 3 : 1

    {
      id: app.id,
      name: app.name,
      app_secret: app.secret_key,
      app_group_name: app.app_group_name,
      max_tps: app.max_tps,
      log_retention_days: app.log_retention_days,
      cluster_name: app.cluster_name,
      consul_host: '',
      consul_hosts: [],
      producer_address: helm_infrastructure&.producer_address,
      status: app.status,
      updated_at: app.updated_at.strftime(Figaro.env.timestamp_format),
      meta: {
        service_names: app.app_group.helm_infrastructure.default_service_names,
        kafka:{
          topic_name: app.topic_name,
          partition: 50,
          replication_factor: replication_factor,
          consumer_group: 'barito',
        },
        elasticsearch: {
          index_prefix: app.topic_name,
          document_type: 'barito',
        },
      },
    }
  end


end
