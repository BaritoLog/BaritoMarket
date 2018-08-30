class RetryBootstrapWorker
  include Sidekiq::Worker

  def perform(infrastructure_component_id)
    infrastructure_component = InfrastructureComponent.find(
        infrastructure_component_id)
    begin
      bootstrapper = BaritoBlueprint::Bootstrapper.new(
        infrastructure_component.infrastructure,
        ChefSoloBootstrapper.new(Figaro.env.chef_repo_dir),
        private_keys_dir: Figaro.env.container_private_keys_dir,
        private_key_name: Figaro.env.container_private_key,
        username: Figaro.env.container_username,
      )
      bootstrapper.bootstrap_instance!(infrastructure_component)
    rescue JSON::ParserError, StandardError => ex
      logger.warn "Exception: #{ex}"
      infrastructure_component.update_status('BOOTSTRAP_ERROR', ex.to_s)
    end
  end
end
