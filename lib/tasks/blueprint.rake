require 'fileutils'

namespace :blueprint do
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

    BaritoBlueprint::Processor.new(
      blueprint_hash,
      pathfinder_host: Figaro.env.pathfinder_host,
      pathfinder_cluster: Figaro.env.pathfinder_cluster,
      pathfinder_image: Figaro.env.pathfinder_image,
      chef_repo_dir: Figaro.env.chef_repo_dir,
      private_key_name: Figaro.env.container_private_key,
      username: Figaro.env.container_username
    ).process!
  end
end
