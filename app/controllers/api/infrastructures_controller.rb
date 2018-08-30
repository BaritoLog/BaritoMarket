class Api::InfrastructuresController < Api::BaseController
  skip_before_action :authenticate_token

  def profile_by_cluster_name
    @infrastructure = Infrastructure.find_by(
      cluster_name: params[:cluster_name])
    render json: {
      name: @infrastructure.name,
      app_group_name: @infrastructure.app_group_name,
      capacity: @infrastructure.capacity,
      cluster_name: @infrastructure.cluster_name,
      consul_host: @infrastructure.consul_host,
      status: @infrastructure.status,
      provisioning_status: @infrastructure.provisioning_status,
      updated_at: @infrastructure.updated_at.strftime(Figaro.env.timestamp_format),
      meta: {
        # TODO: we should store this somewhere
        service_names: {
          producer: 'barito-flow-producer',
          zookeeper: 'zookeeper',
          kafka: 'kafka',
          consumer: 'barito-flow-consumer',
          elasticsearch: 'elasticsearch',
          kibana: 'kibana',
        },
      },
    }
  end

  def authorize_by_username
    @current_user = User.find_by_username_or_email(params[:username])
    @infrastructure = Infrastructure.
      find_by_cluster_name(params[:cluster_name])

    if @infrastructure.blank?
      render json: {
        success: false, 
        errors: ["Unauthorized: infrastructure #{params[:cluster_name]} is not exists"],
        code: 401
      }, status: :unauthorized and return 
    end

    if @infrastructure.status == Infrastructure.statuses[:inactive]
      render json: {
        success: false,
        errors: ["Unauthorized: infrastructure #{params[:cluster_name]} is inactive"],
        code: 401
      }, status: :unauthorized and return 
    end


    raise Pundit::NotAuthorizedError unless InfrastructurePolicy.new(
      @current_user, @infrastructure).exists?

    render json: "", status: :ok
  end
end
