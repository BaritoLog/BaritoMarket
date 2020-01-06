class RetryBootstrapWorker
  include Sidekiq::Worker

  def perform(infrastructure_component_id)
    infrastructure_component = InfrastructureComponent.
      find(infrastructure_component_id)
    begin
      provisioner = BaritoBlueprint::Provisioner.new(
        infrastructure_component.infrastructure,
        infrastructure_component,
        PathfinderProvisioner.new(
          Figaro.env.pathfinder_host,
          Figaro.env.pathfinder_token,
          Figaro.env.pathfinder_cluster,
          image: Figaro.env.pathfinder_image),
      )
      provisioner.rebootstrap_instance!(infrastructure_component)
    rescue JSON::ParserError, StandardError, NoMethodError => ex
      logger.warn "Exception: #{ex}"
      infrastructure_component.update_status('BOOTSTRAP_ERROR', ex.to_s)
    end
  end
end
