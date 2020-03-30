desc 'Create manifest from existing container'

task :manifest_seed => :environment do
  pathfinder_host = Figaro.env.pathfinder_host
  pathfinder_token = Figaro.env.pathfinder_token
  pathfinder_cluster = Figaro.env.pathfinder_cluster
  provisioner = PathfinderProvisioner.new(pathfinder_host, pathfinder_token, pathfinder_cluster)

  components = InfrastructureComponent.joins(:infrastructure).where(infrastructures: {provisioning_status: 'FINISHED'})
  components.each do |component|
    provisioner.update_container!(component)
  end
end