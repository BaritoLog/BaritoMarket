class Api::V2::InfrastructuresController < Api::V2::BaseController
  def profile_index
    profiles = []

    app_groups = AppGroup.ACTIVE.all
    .offset((params.fetch(:page, 1).to_i - 1) * params.fetch(:limit, 10).to_i)
    .limit(params.fetch(:limit, 10).to_i)

    app_groups.each do |app_group|
      if app_group.helm_infrastructures.length == 0
        next
      end

      infra = app_group.helm_infrastructure_in_default_location.present? ?
        app_group.helm_infrastructure_in_default_location :
        app_group.helm_infrastructures.first

      profiles << {
        name: app_group.name,
        app_group_name: app_group.name,
        app_group_secret: app_group.secret_key,
        cluster_name: app_group.cluster_name,
        consul_hosts: [],
        status: app_group.status,
        provisioning_status: infra.provisioning_status,
        meta: {
          service_names: infra.default_service_names
        },
      }
    end
    render json: profiles
  end

  def helm_infrastructure_by_cluster_name
    app_group = AppGroup.find_by(cluster_name: params[:cluster_name])
    if app_group.present?
      @helm_infrastructure = app_group.helm_infrastructure_in_default_location.present? ?
        app_group.helm_infrastructure_in_default_location :
        app_group.helm_infrastructures.first

    end

    if @helm_infrastructure.blank?
      render(json: {
               success: false,
               errors: ['Infrastructure not found'],
               code: 404,
             }, status: :not_found)
    else
      render json: @helm_infrastructure
    end
  end

  def update_helm_manifest_by_cluster_name
    @app_group = AppGroup.ACTIVE.find_by(cluster_name: params[:cluster_name])
    if @app_group.present?
      @helm_infrastructure = @app_group.helm_infrastructure_in_default_location
      @helm_infrastructure = @app_group.helm_infrastructures.active.first unless @helm_infrastructure.active?
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

    if @app_group.present?
      @helm_infrastructure = @app_group.helm_infrastructure_in_default_location
      @helm_infrastructure = @app_group.helm_infrastructures.active.first unless @helm_infrastructure.active?
    end

    if @helm_infrastructure.blank? || !@helm_infrastructure.active?
      render(json: {
               success: false,
               errors: ['Infrastructure not found'],
               code: 404,
             }, status: :not_found) && return
    end
    
    if Figaro.env.ARGOCD_ENABLED == 'true'
      @helm_infrastructure.update!(last_log: "Argo Application sync will be scheduled.")
      @helm_infrastructure.argo_upsert_and_sync
    else
      @helm_infrastructure.update!(last_log: "Helm invocation job will be scheduled.")
      @helm_infrastructure.synchronize_async
    end
    render json: @helm_infrastructure
  end

  def profile_by_cluster_name
    @app_group = AppGroup.ACTIVE.find_by(cluster_name: params[:cluster_name])

    if @app_group.present?
      @helm_infrastructure = @app_group.helm_infrastructure_in_default_location
      @helm_infrastructure = @app_group.helm_infrastructures.active.first unless @helm_infrastructure.active?
    end

    if @helm_infrastructure.blank? || !@helm_infrastructure.active?
      render(json: {
               success: false,
               errors: ['Infrastructure not found'],
               code: 404,
             }, status: :not_found) && return
    end

    render json: {
      name: @helm_infrastructure.app_group_name,
      app_group_name: @helm_infrastructure.app_group_name,
      app_group_id: @helm_infrastructure.app_group_id,
      app_group_secret: @helm_infrastructure.app_group_secret,
      capacity: @helm_infrastructure.helm_cluster_template.name,
      cluster_name: @helm_infrastructure.cluster_name,
      consul_host: '',
      consul_hosts: [],
      kibana_address: @app_group&.kibana_address,
      elasticsearch_address: @app_group&.elasticsearch_address,
      elasticsearch_status: @app_group&.elasticsearch_status,
      kibana_mtls_enabled: @app_group&.kibana_mtls_enabled?,
      status: @helm_infrastructure.status,
      provisioning_status: @helm_infrastructure.provisioning_status,
      created_at: @helm_infrastructure.created_at.strftime(Figaro.env.timestamp_format),
      updated_at: @helm_infrastructure.updated_at.strftime(Figaro.env.timestamp_format),
      meta: {
        service_names: @helm_infrastructure.default_service_names
      },
    }
  end


  def profile_by_app_group_name
    @app_group = AppGroup.find_by(
      name: params[:app_group_name]
    )

    if @app_group.blank? || !@app_group.ACTIVE?
      render(json: {
               success: false,
               errors: ['App Group not found'],
               code: 404,
             }, status: :not_found) && return
    end

    @helm_infrastructure = @app_group.helm_infrastructure_in_default_location
    @helm_infrastructure = @app_group.helm_infrastructures.active.first unless @helm_infrastructure.active?

    render json: {
      app_group_name: @app_group.name,
      app_group_secret: @app_group.secret_key,
      capacity: @helm_infrastructure.helm_cluster_template.name,
      cluster_name: @helm_infrastructure.cluster_name,
      kibana_address: @app_group&.kibana_address,
      kibana_mtls_enabled: @app_group&.kibana_mtls_enabled?,
      status: @helm_infrastructure.status,
      provisioning_status: @helm_infrastructure.provisioning_status,
      updated_at: @helm_infrastructure.updated_at.strftime(Figaro.env.timestamp_format),
      meta: {
        service_names: @helm_infrastructure.default_service_names
      },
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
end
