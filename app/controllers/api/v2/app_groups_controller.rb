class Api::V2::AppGroupsController < Api::V2::BaseController
  include Wisper::Publisher

  def create_app_group
    errors = []

    # ToDo(clavinjune) disable DEFAULT_REQUIRED_LABELS on API
    # required_labels = Figaro.env.DEFAULT_REQUIRED_LABELS.split(',', -1)
    #
    # # force request to have labels if DEFAULT_REQUIRED_LABELS is defined
    # if required_labels.present?
    #   if app_group_params[:labels].nil? || app_group_params[:labels].empty?
    #     errors << "labels attributes are required for #{required_labels}"
    #   end
    #
    #   unless errors.empty?
    #     return render json: {
    #       success: false,
    #       errors: errors,
    #       code: 400
    #     }, status: :bad_request
    #   end
    #
    #   labels = app_group_params[:labels]
    #
    #   required_labels.each do |label|
    #     val = labels[label]
    #     if val.nil? || val.strip.empty?
    #       errors << "labels attributes are required for #{label}"
    #     end
    #   end
    #
    #   unless errors.empty?
    #     return render json: {
    #       success: false,
    #       errors: errors,
    #       code: 400
    #     }, status: :bad_request
    #   end
    # end

    if not app_group_params.blank?
      begin
        @app_group, @infrastructure = AppGroup.setup(app_group_params)
      rescue StandardError => e
        errors << e.message
      end

      if @app_group.blank?
        errors << "No new app group was created"
      end
    end

    if errors.empty? && !app_group_params.blank?
      render json: {
        data: @app_group
      }, status: :ok
    else
      render json: {
        success: false,
        errors: errors,
        code: 404
      }, status: :not_found
    end
  end

  def check_app_group
    valid, error_response = validate_required_keys(
      [:app_group_secret])
    render json: error_response, status: error_response[:code] and return unless valid

    app_group = AppGroup.find_by(secret_key: params[:app_group_secret])

    if app_group.blank?
      render json: {
        success: false,
        errors: ["AppGroup is not found"],
        code: 404
      }, status: :not_found and return
    end

    @helm_infrastructure = app_group.helm_infrastructure_in_default_location.present? ?
      app_group.helm_infrastructure_in_default_location :
      app_group.helm_infrastructures.first

    render json: @helm_infrastructure
  end

  def cluster_templates

    cluster_templates = HelmClusterTemplate.all.map do |cluster|
      cluster.slice(:id, :name)
    end

    if cluster_templates.blank?
      render json: {
        success: false,
        errors: ["Cluster templates are not found"],
        code: 404
      }, status: :not_found and return
    end

    render json: cluster_templates
  end

  def profile_app
    profiles = []
    AppGroup.ACTIVE.all.each do |app_group|
      environment = app_group.environment

      if app_group.environment.downcase.include?"production"
        replication_factor = 2
      else
        replication_factor = 1
      end

      barito_apps =[]
      app_group.barito_apps.where(status:"ACTIVE").each do |barito_app|
        days = barito_app.log_retention_days
        if days == nil
          days = app_group.log_retention_days
        end
        barito_apps << {
          app_labels: barito_app.labels,
          app_log_retention: days,
          app_max_tps: barito_app.max_tps,
          app_name: barito_app.name,
        }
      end

      profiles << {
        app_group_barito_apps: barito_apps,
        app_group_cluster_name: app_group.cluster_name,
        app_group_environment: app_group.environment,
        app_group_labels: app_group.labels,
        app_group_log_retention: app_group.log_retention_days,
        app_group_max_tps: app_group.max_tps,
        app_group_name: app_group.name,
        app_group_replication_factor: replication_factor,
      }
    end
    render json: profiles
  end

  def update_cost
    affected_app = 0
    cost_data = params[:data]

    cost_data.each do |cost_datum|
      app_group = AppGroup.find_by(name: cost_datum[:app_group_name])
      if app_group.blank? || !app_group.available?
        next
      end

      app = BaritoApp.find_by(
        app_group: app_group,
        name: cost_datum[:app_name]
      )
      if app.blank? || !app.available?
        next
      end

      app.update(
        latest_cost: cost_datum[:calculation_price],
        latest_ingested_log_bytes: cost_datum[:app_log_bytes],
      )
      affected_app += 1
    end

    render json: {
      success: true,
      affected_app: affected_app
    }, status: :ok and return
  end

  def deactivated_by_cluster_name
    cluster_name = params[:cluster_name]
    app_group_name = params[:app_group_name]

    # Validate presence of both cluster_name and app_group_name
    unless cluster_name.present? && app_group_name.present?
      render(json: {
        success: false,
        errors: ['Both cluster_name and app_group_name are required'],
        code: 400,
      }, status: :bad_request) && return
    end

    app_group = AppGroup.find_by(cluster_name: cluster_name, name: app_group_name, status: :ACTIVE)
    # if not found
    if app_group.blank?
      render(json: {
        success: false,
        errors: ['App Group not found'],
        code: 404,
      }, status: :not_found) && return
    end

    # set the appgroup to INACTIVE
    app_group.update!(status: :INACTIVE)

    # set each app as INACTIVE
    app_group.barito_apps.each do |app|
      app.update_status('INACTIVE') if app.status == BaritoApp.statuses[:active]
    end

    if Figaro.env.ARGOCD_ENABLED == 'true'
      app_group.helm_infrastructures.each do |helm_infrastructure|
        ArgoDeleteWorker.perform_async(helm_infrastructure.id)
      end
    else
      app_group.helm_infrastructures.each do |helm_infrastructure|
        helm_infrastructure.update_provisioning_status('DELETE_STARTED')
        DeleteHelmInfrastructureWorker.perform_async(helm_infrastructure.id)
      end
    end

    render json: {
      success: true,
      message: 'App Group deactivated successfully',
    }, status: :ok and return
  end

  def fetch_redact_labels
    helm_infrastructure = HelmInfrastructure.find_by(
      cluster_name: params[:cluster_name])

    redact_response_json = REDIS_CACHE.get(
      "#{APP_GROUP_REDACT_LABELS}:#{params[:cluster_name]}")
    if redact_response_json.present?
      render json: JSON.parse(redact_response_json) and return
    end

    all_labels = {}
    app_group = AppGroup.find(helm_infrastructure.app_group_id)
    if app_group.blank? || !app_group.available?
      render json: {
        success: false,
        errors: ['AppGroup not found or inactive'],
        code: 404
      }, status: :not_found and return
    end

    if !app_group.redact_active?
      render json: {} and return
    end

    static, jsonPath = accumulate_rules(app_group)
    all_labels['default'] = {
      StaticRules: static,
      JsonPathRules: jsonPath,
    }

    barito_apps =[]
    app_group.barito_apps.where(status:"ACTIVE").each do |barito_app|
      static, jsonPath = accumulate_rules(barito_app)
      if !static.empty? || !jsonPath.empty?
        all_labels[barito_app.name] = {
          StaticRules: static,
          JsonPathRules: jsonPath,
        }
      end
    end

    broadcast(:redact_response_updated, params[:cluster_name], all_labels)

    render json: all_labels
  end

  private

  def app_group_params
    params.permit(:name, :cluster_template_id, :environment, :infrastructure_location_name,
      labels: {},
      redact_labels: {},
    )
  end

  def accumulate_rules(obj)
    static_rule = []
    json_path_rule = []

    obj.redact_labels&.each do |key, val|
      if val['type'] == 'jsonPath'
        json_path_rule << {
          Name: key,
          Path: val['value'],
          HintCharsStart: Integer(val['hintCharStart']),
          HintCharsEnd: Integer(val['hintCharEnd'])
        }
      elsif val['type'] == 'static'
        static_rule << {
          Name: key,
          Regex: val['value'],
          HintCharsStart: Integer(val['hintCharStart']),
          HintCharsEnd: Integer(val['hintCharEnd'])
        }
      end
    end
    [static_rule, json_path_rule]
  end
end
