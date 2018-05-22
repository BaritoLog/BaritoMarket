class BlueprintWorker
  include Sidekiq::Worker

  def perform(filepath)
    begin
      file = File.read(filepath)
      blueprint_hash = JSON.parse(file)
    rescue StandardError => e
      puts "Caught the exception: #{e}"
      exit -1
    end

    BlueprintProcessor.new(blueprint_hash).process!
  end 
end