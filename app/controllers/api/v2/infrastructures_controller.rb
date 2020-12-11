class Api::V2::InfrastructuresController < Api::V2::BaseController
  def profile_index
    profiles = []
    infrastructures = Infrastructure.where(
      status: Infrastructure.statuses[:active],
      provisioning_status: Infrastructure.provisioning_statuses[:deployment_finished]
    )
    .offset((params.fetch(:page, 1).to_i - 1) * params.fetch(:limit, 10).to_i)
    .limit(params.fetch(:limit, 10).to_i)
    
    infrastructures.each do |infra|
      consul_hosts, consul_host = determine_consul_host(infra)
      profiles << {
        name: infra.name,
        app_group_name: infra.app_group_name,
        app_group_secret: infra.app_group_secret,
        cluster_name: infra.cluster_name,
        consul_hosts: consul_hosts,
        status: infra.status,
        provisioning_status: infra.provisioning_status,
        meta: {
          service_names: infra.default_service_names
        },
      }
    end
    render json: profiles
  end

  def profile_by_cluster_name
    @infrastructure = Infrastructure.find_by(
      cluster_name: params[:cluster_name],
    )

    if @infrastructure.blank? || !@infrastructure.active?
      render(json: {
               success: false,
               errors: ['Infrastructure not found'],
               code: 404,
             }, status: :not_found) && return
    end

    consul_hosts, consul_host = determine_consul_host(@infrastructure)

    render json: {
      name: @infrastructure.name,
      app_group_name: @infrastructure.app_group_name,
      app_group_secret: @infrastructure.app_group_secret,
      capacity: @infrastructure.capacity,
      cluster_name: @infrastructure.cluster_name,
      consul_host: consul_host,
      consul_hosts: consul_hosts,
      status: @infrastructure.status,
      provisioning_status: @infrastructure.provisioning_status,
      updated_at: @infrastructure.updated_at.strftime(Figaro.env.timestamp_format),
      meta: {
        service_names: @infrastructure.default_service_names
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
      next if app_group.infrastructure == nil
      next unless [
        Infrastructure.provisioning_statuses[:finished],
        Infrastructure.provisioning_statuses[:deployment_finished]
      ].include? app_group.infrastructure.provisioning_status

      es_component = app_group.infrastructure.infrastructure_components.where(
        component_type: 'elasticsearch',
        status: InfrastructureComponent.statuses[:finished],
      ).first
      es_ipaddress = es_component.nil? ? '' : es_component.ipaddress
      es_ipaddresses = app_group.infrastructure.fetch_manifest_ipaddresses('elasticsearch')

      next if es_ipaddress.empty? && es_ipaddresses.empty?

      es_ipaddress = es_ipaddresses.empty? ? es_ipaddress : es_ipaddresses.first

      profiles << {
        ipaddress: es_ipaddress,
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
    @infrastructure = Infrastructure.
      find_by_cluster_name(params[:cluster_name])

    if @current_user.blank? || @infrastructure.blank? || !@infrastructure.active? ||
        !InfrastructurePolicy.new(@current_user, @infrastructure).exists?
      render(json: {
               success: false,
               errors: ['Forbidden'],
               code: 403,
             }, status: :forbidden) && return
    end

    render json: '', status: :ok
  end
end
