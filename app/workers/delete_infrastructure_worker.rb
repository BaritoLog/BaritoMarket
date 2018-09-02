class DeleteInfrastructureWorker
  include Sidekiq::Worker

  def perform(infrastructure_id)
    infrastructure = Infrastructure.
      find(infrastructure_id)
    begin
      provisioner = BaritoBlueprint::Provisioner.new(
        infrastructure,
        PathfinderProvisioner.new(
          Figaro.env.pathfinder_host,
          Figaro.env.pathfinder_token,
          Figaro.env.pathfinder_cluster,
          pathfinder_image: Figaro.env.pathfinder_image),
      )
      provisioner.delete_instances!
    rescue JSON::ParserError, StandardError => ex
      logger.warn "Exception: #{ex}"
      infrastructure.update_status('PROVISIONING_ERROR', ex.to_s)
    end
  end
end
