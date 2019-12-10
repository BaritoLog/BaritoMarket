module BaritoBlueprint
  class Processor
    attr_accessor :instances_hash, :infrastructure

    def initialize(instances_hash, opts = {})
      @instances_hash = instances_hash
      @infrastructure = Infrastructure.find(
        opts[:infrastructure_id])

      # Provisioner and bootstrapper attributes
      @pathfinder_host    = opts[:pathfinder_host]
      @pathfinder_token   = opts[:pathfinder_token]
      @pathfinder_cluster = opts[:pathfinder_cluster]
      @chef_repo_dir      = opts[:chef_repo_dir]
      @username           = opts[:username]
    end

    def process_check!
      provision = false
      @instances_hash.each_with_index do |node,seq|
        @infrastructure.add_component(node, seq+1)
      end

      seq_components = @infrastructure.infrastructure_components.where(component_type: 'consul')
      if !seq_components.empty?
        provision = process!(seq_components)
      end

      @infrastructure.reload
      components = @infrastructure.infrastructure_components.where.not(component_type: 'consul')
      if !components.empty?
        provision = process!(components)
      end

      return provision
    end

    def process!(components)
      bootstrapper = Bootstrapper.new(
        @infrastructure,
        components,
        username: @username,
      )
      return false unless bootstrapper.bootstrap_instances!

      @infrastructure.reload
      sleep(5) unless Rails.env.test?

      provisioner = Provisioner.new(
        @infrastructure,
        components,
        PathfinderProvisioner.new(
          @pathfinder_host, @pathfinder_token, @pathfinder_cluster),
      )
      
      return false unless provisioner.provision_instances!
      return false unless provisioner.check_and_update_instances
      
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
