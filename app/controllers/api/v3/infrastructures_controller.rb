class Api::V3::InfrastructuresController < Api::V2::BaseController
  def helm_infrastructures_by_cluster_name
    @helm_infrastructures = HelmInfrastructure.where(
      cluster_name: params[:cluster_name],
      status: HelmInfrastructure.statuses[:active],
    ).includes(:infrastructure_location).all

    if @helm_infrastructures.empty?
      render(json: {
               success: false,
               errors: ['Infrastructures not found'],
               code: 404,
             }, status: :not_found)
    else
      render json: @helm_infrastructures.as_json(include: :infrastructure_location)
    end
  end

  def update_helm_manifest_by_cluster_name
    @app_group = AppGroup.ACTIVE.find_by(cluster_name: params[:cluster_name])
    location = InfrastructureLocation.active.find_by(name: params[:location_name])

    if @app_group.present? and location.present?
      @helm_infrastructure = @app_group.helm_infrastructures.where(infrastructure_location_id: location.id).first
    end

    if @helm_infrastructure.blank? || !@helm_infrastructure.active?
      render(json: {
               success: false,
               errors: ['Infrastructure not found'],
               code: 404,
             }, status: :not_found) && return
    end

    ov = params[:override_values]
    if ov.nil?
      render(json: {
               success: false,
               errors: ['Invalid payload'],
               code: 400,
             }, status: :bad_request) && return
    end

    if @helm_infrastructure.update({override_values: ov})
      render json: @helm_infrastructure
    else
      render(json: {
               success: false,
               errors: ['Invalid payload'],
               code: 400,
             }, status: :bad_request) && return
    end
  end

  def sync_helm_infrastructure_by_cluster_name
    @app_group = AppGroup.ACTIVE.find_by(cluster_name: params[:cluster_name])
    location = InfrastructureLocation.active.find_by(name: params[:location_name])

    if @app_group.present? and location.present?
      @helm_infrastructure = @app_group.helm_infrastructures.where(infrastructure_location_id: location.id).first
    end


    if @helm_infrastructure.blank? || !@helm_infrastructure.active?
      render(json: {
               success: false,
               errors: ['Infrastructure not found'],
               code: 404,
             }, status: :not_found) && return
    end

    @helm_infrastructure.synchronize_async
    render json: @helm_infrastructure
  end

  def profile_by_cluster_name
    @app_group = AppGroup.find_by(
      cluster_name: params[:cluster_name],
    )

    if @app_group.blank? || !@app_group.ACTIVE?
      render(json: {
               success: false,
               errors: ['App Group not found'],
               code: 404,
             }, status: :not_found) && return
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

  def profile_index
    profiles = []

    app_groups = AppGroup.ACTIVE.all
    .offset((params.fetch(:page, 1).to_i - 1) * params.fetch(:limit, 10).to_i)
    .limit(params.fetch(:limit, 10).to_i)

    app_groups.each do |app_group|
      profiles << {
        name: app_group.name,
        secret_key: app_group.secret_key,
        cluster_name: app_group.cluster_name,
        status: app_group.status,
      }
    end
    render json: profiles
  end

  def authorize_by_username
    @current_user = User.find_by_username_or_email(params[:username])
    @app_group = AppGroup.find_by_cluster_name(params[:cluster_name])

    if @current_user.blank? || @app_group.blank? || @app_group.INACTIVE? ||
        !AppGroupPolicy.new(@current_user, @app_group).see_app_groups?

      render(json: {
               success: false,
               errors: ['Forbidden'],
               code: 403,
             }, status: :forbidden) && return
    end

    render json: '', status: :ok
  end

  def profile_by_app_group_name
    @app_group = AppGroup.find_by(
      name: params[:app_group_name],
    )

    if @app_group.blank? || !@app_group.ACTIVE?
      render(json: {
               success: false,
               errors: ['App Group not found'],
               code: 404,
             }, status: :not_found) && return
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

  def profile_curator
    if Figaro.env.es_curator_client_key != params[:client_key]
      render(json: {
               success: false,
               errors: ['Unauthorized'],
               code: 401,
             }, status: :not_found) && return
    end

    profiles = []
    AppGroup.all.each do |app_group|
      next if app_group.helm_infrastructures.where(provisioning_status: [
        HelmInfrastructure.provisioning_statuses[:finished],
        HelmInfrastructure.provisioning_statuses[:deployment_finished]]
      ).empty?

      profiles << {
        ipaddress: app_group.elasticsearch_address,
        log_retention_days: app_group.log_retention_days,
        log_retention_days_per_topic: app_group.barito_apps.inject({}) do |app_map, app|
          app_map[app.topic_name] = app.log_retention_days if app.log_retention_days
          app_map
        end
      }
    end

    render json: profiles
  end

  def profile_prometheus_exporter
    infrastructure_components = InfrastructureComponent.joins(infrastructure: :app_group).where(
      status: InfrastructureComponent.statuses[:finished],
    )

    render json: infrastructure_components.map { |infrastructure_component|
      infrastructure = infrastructure_component.infrastructure
      app_group = infrastructure.app_group
      {
        cluster_name: infrastructure.cluster_name,
        component_type: infrastructure_component.component_type,
        environment: app_group.environment,
        ipaddress: infrastructure_component.ipaddress,
      }
    }
  end


end
