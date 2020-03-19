class UpdateManifestsWorker
  include Sidekiq::Worker

  def perform(infrastructure_id)
    begin
      infrastructure = Infrastructure.find!(infrastructure_id)
      provisioner = BaritoBlueprint::Provisioner.new(
        infrastructure,
        PathfinderProvisioner.new(
          Figaro.env.pathfinder_host,
          Figaro.env.pathfinder_token,
          Figaro.env.pathfinder_cluster,
        )
      )
      provisioner.bulk_apply!
    rescue JSON::ParserError, StandardError, NoMethodError => ex
      logger.warn "Exception: #{ex}"
      infrastructure.update_provisioning_status('DEPLOYMENT_ERROR')
    end
  end
end
