# DEPRECATION NOTICE
# This API and all of its inherited APIs will be deprecated in favor of v2
class Api::InfrastructuresController < Api::BaseController
  def profile_by_cluster_name
    # removed
    render(json: {
              success: false,
              errors: ['Api removed, please use v2'],
              code: 404,
            }, status: :not_found)
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
