class Api::InfrastructuresController < Api::BaseController
  skip_before_action :authenticate_token, only: [:profile_by_cluster_name]

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
end
