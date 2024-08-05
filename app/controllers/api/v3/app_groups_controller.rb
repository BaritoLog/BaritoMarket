class Api::V3::AppGroupsController < Api::V3::BaseController
  include Wisper::Publisher

  def create_app_group
    errors = []

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

    @app_group = AppGroup.find_by(secret_key: params[:app_group_secret])

    if @app_group.blank?
      render json: {
        success: false,
        errors: ["AppGroup is not found"],
        code: 404
      }, status: :not_found and return
    end

    render json: {
      id: @app_group.id,
      name: @app_group.name,
      secret_key: @app_group.secret_key,
      cluster_name: @app_group.cluster_name,
      kibana_address: @app_group.kibana_address,
      status: @app_group.status,
      created_at: @app_group.created_at.strftime(Figaro.env.timestamp_format),
      updated_at: @app_group.updated_at.strftime(Figaro.env.timestamp_format),
      infrastructures: @app_group.helm_infrastructures
    }
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

    # delete all the HelmInfra, and mark as DELETE_STARTED
    app_group.helm_infrastructures.each do |hi|
      hi.update_provisioning_status('DELETE_STARTED')
      DeleteHelmInfrastructureWorker.perform_async(hi.id)
    end

    render json: {
      success: true,
      message: 'App Group deactivated successfully',
    }, status: :ok and return
  end

  private

  def app_group_params
    params.permit(:name, :cluster_template_id, :environment, :infrastructure_location_name,
      labels: {},
    )
  end
end
