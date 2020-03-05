class BlueprintWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(opts = {})
    begin
      BaritoBlueprint::Processor.new(
        infrastructure_id: opts["infrastructure_id"],
        pathfinder_host: Figaro.env.pathfinder_host,
        pathfinder_token: Figaro.env.pathfinder_token,
        pathfinder_cluster: Figaro.env.pathfinder_cluster,
        chef_repo_dir: Figaro.env.chef_repo_dir
      ).process!
    rescue JSON::ParserError, StandardError => ex
      logger.warn "Exception: #{ex}"
    end
  end
end
