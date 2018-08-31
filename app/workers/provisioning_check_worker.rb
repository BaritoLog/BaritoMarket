class ProvisioningCheckWorker
  include Sidekiq::Worker

  def perform(infrastructure_component_id)
    infrastructure_component = InfrastructureComponent.
      find(infrastructure_component_id)
    begin
      provisioner = BaritoBlueprint::Provisioner.new(
        infrastructure_component.infrastructure,
        PathfinderProvisioner.new(
          Figaro.env.pathfinder_host,
          Figaro.env.pathfinder_token,
          Figaro.env.pathfinder_cluster,
          pathfinder_image: Figaro.env.pathfinder_image),
      )
      provisioner.check_and_update_instance(infrastructure_component,
        update_status: true)
    rescue JSON::ParserError, StandardError => ex
      logger.warn "Exception: #{ex}"
      infrastructure_component.update_status('PROVISIONING_CHECK_FAILED',
        ex.to_s)
    end
  end
end
