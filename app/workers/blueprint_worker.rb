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
          pathfinder_host: Figaro.env.pathfinder_host,
          pathfinder_token: Figaro.env.pathfinder_token,
          pathfinder_cluster: Figaro.env.pathfinder_cluster,
          pathfinder_image: Figaro.env.pathfinder_image,
          chef_repo_dir: Figaro.env.chef_repo_dir,
          private_keys_dir: Figaro.env.container_private_keys_dir,
          private_key_name: Figaro.env.container_private_key,
          username: Figaro.env.container_username
        ).process!
      rescue JSON::ParserError, StandardError => ex
        logger.warn "Exception: #{ex}"
      end
    end
  end
end
