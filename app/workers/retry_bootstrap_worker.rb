class RetryBootstrapWorker
  include Sidekiq::Worker

  def perform(seq, infrastructure_id)
    begin
      infrastructure = Infrastructure.find(infrastructure_id)
      ordered_infrastructure_components = infrastructure.infrastructure_components.order(:sequence)

       blueprint_processor = BlueprintProcessor.new(
        nil,

        # TODO: remove these references when sauron can
        # schedule containers automatically
        sauron_host: Figaro.env.sauron_host,
        username: Figaro.env.container_username,
        private_key_name: Figaro.env.container_private_key,
        infrastructure_id: infrastructure.id,
      ).bootstrap_instances!(ordered_infrastructure_components, seq)
    rescue JSON::ParserError, StandardError => ex
      raise Exception.new("Exception: #{ex}")
    end
  end
end
