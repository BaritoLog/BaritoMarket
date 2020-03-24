module BaritoBlueprint
  class Processor
    attr_accessor :infrastructure

    def initialize(opts = {})
      @infrastructure = Infrastructure.find(opts[:infrastructure_id])

      # Provisioner and bootstrapper attributes
      @pathfinder_host    = opts[:pathfinder_host]
      @pathfinder_token   = opts[:pathfinder_token]
      @pathfinder_cluster = opts[:pathfinder_cluster]
      @chef_repo_dir      = opts[:chef_repo_dir]
    end

    def process!()
      bootstrapper = Bootstrapper.new(
        @infrastructure,
        pathfinder_cluster: @pathfinder_cluster
      )
      return false unless bootstrapper.generate_manifests!

      @infrastructure.reload
      sleep(5) unless Rails.env.test?

      provisioner = Provisioner.new(
        @infrastructure,
        PathfinderProvisioner.new(
          @pathfinder_host, @pathfinder_token, @pathfinder_cluster),
      )
      
      return false unless provisioner.batch!
      
      return true
    end

    def self.produce_log(infrastructure, *msgs)
      log = []
      log << "Infrastructure:#{infrastructure.id}"
      log |= msgs
      Rails.logger.info log.join(' -- ')
    end
  end
end
