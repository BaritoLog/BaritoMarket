class RetryBootstrapWorker
  include Sidekiq::Worker

  def perform(infrastructure_id, seq)
    begin
      infrastructure = Infrastructure.find(infrastructure_id)
      ordered_infrastructure_components = infrastructure.infrastructure_components.order(:sequence)

      blueprint_hash = { infrastructure_id: infrastructure.id }
      opts = {
        sauron_host: Figaro.env.sauron_host,
        private_key_name: Figaro.env.container_private_key,
        username: Figaro.env.container_username,
      }
      blueprint_processor = BlueprintProcessor.new(blueprint_hash, opts)
      blueprint_processor.bootstrap_instances!(
        ordered_infrastructure_components, seq)
    rescue JSON::ParserError, StandardError => ex
      logger.warn "Exception: #{ex}"
    end
  end
end
