module BaritoBlueprint
  class Processor
    DEFAULTS = {
      private_keys_dir: "#{Rails.root}/config/private_keys"
    }

    attr_accessor :instances_hash, :infrastructure

    def initialize(instances_hash, opts = {})
      @instances_hash = instances_hash
      @infrastructure = Infrastructure.find(
        opts[:infrastructure_id])

      # Provisioner and bootstrapper attributes
      @pathfinder_host = opts[:pathfinder_host]
      @pathfinder_token = opts[:pathfinder_token]
      @pathfinder_cluster = opts[:pathfinder_cluster]
      @chef_repo_dir = opts[:chef_repo_dir]

      # Private keys
      @private_keys_dir     = opts[:private_keys_dir] ||
        DEFAULTS[:private_keys_dir]
      @private_key_name     = opts[:private_key_name]
      @username             = opts[:username]
    end

    def process!
      @instances_hash.each_with_index do |node, seq|
        @infrastructure.add_component(node, seq+1)
      end
      provisioner = Provisioner.new(
        @infrastructure,
        PathfinderProvisioner.new(
          @pathfinder_host, @pathfinder_token, @pathfinder_cluster),
      )
      
      return false unless provisioner.provision_instances!
      return false unless provisioner.check_and_update_instances

      # Give time for the machines to finish initializing
      # TODO: should find a better way to detect dpkg lock
      sleep(5) unless Rails.env.test?

      bootstrapper = Bootstrapper.new(
        @infrastructure,
        ChefSoloBootstrapper.new(@chef_repo_dir),
        private_keys_dir: @private_keys_dir,
        private_key_name: @private_key_name,
        username: @username,
      )
      return false unless bootstrapper.bootstrap_instances!

      @infrastructure.reload

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
