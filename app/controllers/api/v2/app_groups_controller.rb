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
      @app_group, @infrastructure = AppGroup.setup(app_group_params)
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

    render json: app_group.helm_infrastructure
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
    AppGroup.active.all.each do |appGroup|
      environment = appGroup.environment
      helm_infra = appGroup.helm_infrastructure

      template = HelmClusterTemplate.find_by(id: helm_infra.helm_cluster_template_id)

      if template.name.downcase.include?"production"
        replication_factor = 2
      else
        replication_factor = 1
      end

      barito_apps =[]
      appGroup.barito_apps.where(status:"ACTIVE").each do |barito_app|
        days = barito_app.log_retention_days
        if days == nil
          days = appGroup.log_retention_days
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
        app_group_cluster_name: helm_infra.cluster_name,
        app_group_environment: appGroup.environment,
        app_group_labels: appGroup.labels,
        app_group_log_retention: appGroup.log_retention_days,
        app_group_max_tps: appGroup.helm_infrastructure.max_tps,
        app_group_name: appGroup.name,
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
    app_group_name = params[:name]
  
    # Validate presence of both cluster_name and app_group_name
    unless cluster_name.present? && app_group_name.present?
      render(json: {
        success: false,
        errors: ['Both cluster_name and app_group_name are required'],
        code: 400,
      }, status: :bad_request) && return
    end
  
    @helm_infrastructure = HelmInfrastructure.find_by(cluster_name: cluster_name)
  
    if @helm_infrastructure.blank? || !@helm_infrastructure.active?
      render(json: {
        success: false,
        errors: ['Helm Infrastructure not found'],
        code: 404,
      }, status: :not_found) && return
    end
  
    # Check if the Helm Infrastructure's app_group_name matches the provided app_group_name
    unless @helm_infrastructure.app_group.name == app_group_name
      render(json: {
        success: false,
        errors: ['Mismatched app_group_name and cluster_name'],
        code: 400,
      }, status: :bad_request) && return
    end
  
    app_group = @helm_infrastructure.app_group
    barito_apps = app_group.barito_apps 
    barito_apps.each do |app|
      app.update_status('INACTIVE') if app.status == BaritoApp.statuses[:active]
    end
  
    @helm_infrastructure.update_provisioning_status('DELETE_STARTED')
    DeleteHelmInfrastructureWorker.perform_async(@helm_infrastructure.id)
  
    render json: {
      success: true,
      message: 'App Group deactivated successfully',
    }
  end

  private

  def app_group_params
    params.permit(:name, :cluster_template_id, :environment,
      labels: {},
    )
  end
end
