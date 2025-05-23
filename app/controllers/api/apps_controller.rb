# DEPRECATION NOTICE
# This API and all of its inherited APIs will be deprecated in favor of v2
class Api::AppsController < Api::BaseController
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
        max_tps: Figaro.env.default_app_max_tps,
        labels: app_group.labels
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

  private

  def metric_params
    params.permit({application_groups: [:token, :new_log_count]})
  end

  def generate_profile_response(app)
    environment = app.app_group&.environment
    replication_factor = environment == "production" ? 3 : 1
    {
      id: app.id,
      name: app.name,
      app_secret: app.secret_key,
      app_group_name: app.app_group_name,
      disable_app_tps: app.app_group.disable_app_tps,
      app_group_max_tps: app.app_group.max_tps,
      max_tps: app.max_tps,
      log_retention_days: app.log_retention_days,
      cluster_name: app.cluster_name,
      labels: app.labels,
      consul_host: "",
      consul_hosts: [],
      producer_address: app.app_group&.producer_address,
      producer_mtls_enabled: app.app_group&.producer_mtls_enabled?,
      producer_location: app.app_group&.producer_location,
      kibana_location: app.app_group&.kibana_location,
      status: app.status,
      updated_at: app.updated_at.strftime(Figaro.env.timestamp_format),
      meta: {
        service_names: app.app_group.helm_infrastructures.first.default_service_names,
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
