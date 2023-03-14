class Api::V2::AppGroupsController < Api::V2::BaseController
  include Wisper::Publisher

  def create_app_group
    errors = []

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

      infra_values = helm_infra.values.to_json
      object = JSON.parse(infra_values, object_class: OpenStruct)

      replication_factor = environment == "production" ? 2 : 1

      barito_apps =[]
      appGroup.barito_apps.where(status:"ACTIVE").each do |barito_app|
        days = barito_app.log_retention_days
        if days == nil
          days = environment == "production" ? 14 : 7
        end
        barito_apps << {
          app_name: barito_app.name,
          app_log_retention: days,
        }
      end

      profiles << {
        app_group_name: appGroup.name,
        app_group_cluster_name: helm_infra.cluster_name,
        app_group_replication_factor: replication_factor,
        app_group_barito_apps: barito_apps,
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
        render json: {
          success: false,
          errors: ['AppGroup not found or inactive'],
          code: 404
        }, status: :not_found and return
      end

      app = BaritoApp.find_by(
        app_group: app_group,
        name: cost_datum[:app_name]
      )
      if app.blank? || !app.available?
        render json: {
          success: false,
          errors: ['App not found or inactive'],
          code: 404
        }, status: :not_found and return
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

  private

  def app_group_params
    params.permit(:name, :cluster_template_id,)
  end

end
