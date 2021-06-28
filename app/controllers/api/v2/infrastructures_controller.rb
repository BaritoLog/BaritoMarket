class Api::V2::InfrastructuresController < Api::V2::BaseController
  def profile_index
    profiles = []
    helm_infrastructures = HelmInfrastructure.where(
      status: HelmInfrastructure.statuses[:active],
      provisioning_status: HelmInfrastructure.provisioning_statuses[:deployment_finished]
    )
    .offset((params.fetch(:page, 1).to_i - 1) * params.fetch(:limit, 10).to_i)
    .limit(params.fetch(:limit, 10).to_i)

    helm_infrastructures.each do |infra|
      profiles << {
        name: infra.app_group_name,
        app_group_name: infra.app_group_name,
        app_group_secret: infra.app_group_secret,
        cluster_name: infra.cluster_name,
        consul_hosts: [],
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
    @helm_infrastructure = HelmInfrastructure.find_by(
      cluster_name: params[:cluster_name],
    )

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
      app_group_secret: @helm_infrastructure.app_group_secret,
      capacity: @helm_infrastructure.helm_cluster_template.name,
      cluster_name: @helm_infrastructure.cluster_name,
      consul_host: '',
      consul_hosts: [],
      kibana_address: @helm_infrastructure&.kibana_address,
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
      next if app_group.helm_infrastructure == nil
      next unless [
        HelmInfrastructure.provisioning_statuses[:finished],
        HelmInfrastructure.provisioning_statuses[:deployment_finished]
      ].include? app_group.helm_infrastructure.provisioning_status

      if app_group.helm_infrastructure.present?
        es_address = app_group.helm_infrastructure.elasticsearch_address

        profiles << {
          ipaddress: es_address,
          log_retention_days: app_group.log_retention_days,
          log_retention_days_per_topic: app_group.barito_apps.inject({}) do |app_map, app|
            app_map[app.topic_name] = app.log_retention_days if app.log_retention_days
            app_map
          end
        }
      end
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
    @helm_infrastructure = HelmInfrastructure.
      find_by_cluster_name(params[:cluster_name])

    if @current_user.blank? || @helm_infrastructure.blank? || !@helm_infrastructure.active? ||
        !HelmInfrastructurePolicy.new(@current_user, @helm_infrastructure).exists?
      render(json: {
               success: false,
               errors: ['Forbidden'],
               code: 403,
             }, status: :forbidden) && return
    end

    render json: '', status: :ok
  end
end
