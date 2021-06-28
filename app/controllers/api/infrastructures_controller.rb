# DEPRECATION NOTICE
# This API and all of its inherited APIs will be deprecated in favor of v2
class Api::InfrastructuresController < Api::BaseController
  def profile_by_cluster_name
    @helm_infrastructure = HelmInfrastructure.find_by(
      cluster_name: params[:cluster_name])

    if @helm_infrastructure.blank? || !@helm_infrastructure.active?
      render json: {
        success: false,
        errors: ["Infrastructure not found"],
        code: 404
      }, status: :not_found and return
    end

    render json: {
      name: @helm_infrastructure.app_group_name,
      app_group_name: @helm_infrastructure.app_group_name,
      app_group_secret: @helm_infrastructure.app_group_secret,
      capacity: @helm_infrastructure.helm_cluster_template.name,
      cluster_name: @helm_infrastructure.cluster_name,
      consul_host: '',
      status: @helm_infrastructure.status,
      provisioning_status: @helm_infrastructure.provisioning_status,
      updated_at: @helm_infrastructure.updated_at.strftime(Figaro.env.timestamp_format),
      meta: {
        service_names: @helm_infrastructure.default_service_names,
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

  def authorize_by_username
    @current_user = User.find_by_username_or_email(params[:username])
    @helm_infrastructure = HelmInfrastructure.find_by_cluster_name(params[:cluster_name])

    if @current_user.blank? || @helm_infrastructure.blank? || !@helm_infrastructure.active? || !HelmInfrastructurePolicy.new(@current_user, @helm_infrastructure).exists?
      render json: {
        success: false,
        errors: ["Forbidden"],
        code: 403
      }, status: :forbidden and return
    end

    render json: "", status: :ok
  end
end
