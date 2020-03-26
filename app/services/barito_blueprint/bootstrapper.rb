module BaritoBlueprint
  class Bootstrapper
    BOOTSTRAP_ATTRIBUTES_GENERATORS = {
      'consul' => ChefHelper::ConsulRoleAttributesGenerator,
      'barito-flow-consumer' =>
        ChefHelper::BaritoFlowConsumerRoleAttributesGenerator,
      'barito-flow-producer' =>
        ChefHelper::BaritoFlowProducerRoleAttributesGenerator,
      'elasticsearch' => ChefHelper::ElasticsearchRoleAttributesGenerator,
      'kafka' => ChefHelper::KafkaRoleAttributesGenerator,
      'kibana' => ChefHelper::KibanaRoleAttributesGenerator,
      'yggdrasil' => ChefHelper::YggdrasilRoleAttributesGenerator,
      'zookeeper' => ChefHelper::ZookeeperRoleAttributesGenerator,
    }

    def initialize(infrastructure, opts = {})
      @infrastructure = infrastructure
      @infrastructure_manifests = infrastructure.manifests
      @pathfinder_cluster = opts[:pathfinder_cluster]
    end

    def generate_manifests!
      Processor.produce_log(@infrastructure, 'Bootstrap started')
      @infrastructure.update_provisioning_status('BOOTSTRAP_STARTED')

      @infrastructure_manifests.each_with_index do |manifest, idx|
        primed_manifest, success = generate_manifest!(manifest)
        if !success
          Processor.produce_log(@infrastructure, 'Bootstrap error')
          @infrastructure.update_provisioning_status('BOOTSTRAP_ERROR')
          return false
        end
        @infrastructure.manifests[idx] = primed_manifest
        @infrastructure.save
      end

      Processor.produce_log(@infrastructure, 'Bootstrap finished')
      @infrastructure.update_provisioning_status('BOOTSTRAP_FINISHED')
      return true
    end

    def generate_manifest!(plain_manifest)
      Processor.produce_log(
        @infrastructure,
        "InfrastructureManifest:#{plain_manifest['type']}",
        "Bootstrapping #{plain_manifest['type']} started")

      primed_manifest, success = setup_manifest(plain_manifest)
      if !success
        Processor.produce_log(
          @infrastructure,
          "Infrastructure:#{@infrastructure.name}",
          "Manifest #{plain_manifest['type']} error")
        return nil, false
      end
      Processor.produce_log(
        @infrastructure,
        "Infrastructure:#{@infrastructure.name}",
        "Manifest #{primed_manifest['name']} finished")
      return primed_manifest, true
    end

    def generate_bootstrap_attributes(manifest, infrastructure_manifests)
      generator = BOOTSTRAP_ATTRIBUTES_GENERATORS[manifest['type']]
      return {} unless generator.is_a? Class
      ChefHelper::GenericRoleAttributesGenerator.new.generate(
        generator.new(manifest, infrastructure_manifests))

    end

    def setup_manifest(manifest)
      manifest['deployment_cluster_name'] = "#{@infrastructure.cluster_name}"
      manifest['name'] = "#{manifest['deployment_cluster_name']}-#{manifest['type']}"
      manifest['cluster_name'] = "#{@pathfinder_cluster}"
      bootstrappers = manifest['definition']['bootstrappers']
      bootstrappers.each_with_index do |bootstrapper, idx|
        case bootstrapper['bootstrap_type']
        when "chef-solo"
          if bootstrapper['bootstrap_attributes']['run_list'].empty?
            # Fetch bootstrap attributes
            attrs = generate_bootstrap_attributes(
              manifest, @infrastructure.manifests)      
            bootstrappers[idx]['bootstrap_attributes'] = attrs
          end
          return manifest, true
        else
          return nil, false
        end
      end
    end
  end
end
