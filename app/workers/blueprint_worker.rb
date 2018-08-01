class BlueprintWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(filepath)
    if File.exists?(filepath)
      content = File.read(filepath)
      begin
        blueprint_hash = JSON.parse(content)
        BaritoBlueprint::Processor.new(
          blueprint_hash,
          sauron_host: Figaro.env.sauron_host,
          chef_repo_dir: Figaro.env.chef_repo_dir,
          private_key_name: Figaro.env.container_private_key,
          username: Figaro.env.container_username
        ).process!
      rescue JSON::ParserError, StandardError => ex
        logger.warn "Exception: #{ex}"
      end
    end
  end
end
