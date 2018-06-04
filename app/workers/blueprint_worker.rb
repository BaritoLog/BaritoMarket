class BlueprintWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(filepath)
    if File.exists?(filepath)
      content = File.read(filepath)
      begin
        blueprint_hash = JSON.parse(content)
        BlueprintProcessor.new(blueprint_hash).process!
      rescue JSON::ParseError, StandardError => ex
        logger.warn "Exception: #{ex}"
      end
    end
  end
end
