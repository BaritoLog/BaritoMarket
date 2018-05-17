require 'fileutils'

namespace :blueprint do
  SSH_CONFIG = "ssh-config"
  
  desc 'blueprint related tasks'
  
  task :exec, [:path] => [:environment] do |t, args|
    path = args[:path]

    begin
      file = File.read(path)
      blueprint_hash = JSON.parse(file)
    rescue StandardError => e
      puts "Caught the exception: #{e}"
      exit -1
    end

    BlueprintProcessor.new(blueprint_hash).process!
  end
end
