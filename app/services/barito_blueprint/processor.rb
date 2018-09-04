module BaritoBlueprint
  class Processor
    DEFAULTS = {
      private_keys_dir: "#{Rails.root}/config/private_keys"
    }

    attr_accessor :blueprint_hash, :infrastructure

    def initialize(blueprint_hash, opts = {})
      @blueprint_hash = blueprint_hash.deep_symbolize_keys!
      @infrastructure = Infrastructure.find(
        @blueprint_hash[:infrastructure_id])

      # Provisioner and bootstrapper attributes
      @pathfinder_host = opts[:pathfinder_host]
      @pathfinder_token = opts[:pathfinder_token]
      @pathfinder_cluster = opts[:pathfinder_cluster]
      @pathfinder_image = opts[:pathfinder_image]
      @chef_repo_dir = opts[:chef_repo_dir]

      # Private keys
      @private_keys_dir     = opts[:private_keys_dir] ||
        DEFAULTS[:private_keys_dir]
      @private_key_name     = opts[:private_key_name]
      @username             = opts[:username]
    end

    def process!
      @blueprint_hash[:nodes].each_with_index do |node, seq|
        @infrastructure.add_component(node, seq + 1)
      end

      provisioner = Provisioner.new(
        @infrastructure,
        PathfinderProvisioner.new(
          @pathfinder_host, @pathfinder_token, @pathfinder_cluster, image: @pathfinder_image),
      )
      return false unless provisioner.provision_instances!
      return false unless provisioner.check_and_update_instances

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
