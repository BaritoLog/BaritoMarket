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

    def initialize(infrastructure, executor, opts = {})
      @infrastructure = infrastructure
      @infrastructure_components = @infrastructure.infrastructure_components
      @executor = executor
      @private_keys_dir = opts[:private_keys_dir]
      @private_key_name = opts[:private_key_name]
      @username = opts[:username]
    end

    def bootstrap_instances!
      Processor.produce_log(@infrastructure, 'Bootstrap started')
      @infrastructure.update_provisioning_status('BOOTSTRAP_STARTED')

      @infrastructure_components.order(:sequence).each do |component|
        success = bootstrap_instance!(component)
        unless success
          Processor.produce_log(@infrastructure, 'Bootstrap error')
          @infrastructure.update_provisioning_status('BOOTSTRAP_ERROR')
          return false
        end
      end

      Processor.produce_log(@infrastructure, 'Bootstrap finished')
      @infrastructure.update_provisioning_status('FINISHED')
      @infrastructure.update_status('ACTIVE')
      return true
    end

    def bootstrap_instance!(component)
      Processor.produce_log(
        @infrastructure, 
        "InfrastructureComponent:#{component.id}",
        "Bootstrapping #{component.hostname} started")
      component.update_status('BOOTSTRAP_STARTED')

      # Get private key file path
      private_key = nil
      if @private_keys_dir && @private_key_name
        private_key = File.join(@private_keys_dir, @private_key_name)
      end

      # Fetch bootstrap attributes
      attrs = generate_bootstrap_attributes(
        component, @infrastructure_components)

      # Execute bootstrapping
      res = @executor.bootstrap!(
        component.hostname,
        component.ipaddress,
        @username,
        private_key: private_key,
        attrs: attrs
      )
      Processor.produce_log(
        @infrastructure, 
        "InfrastructureComponent:#{component.id}",
        "#{res}")

      if res['success'] == true
        component.update_attribute(:bootstrap_attributes, attrs)
        Processor.produce_log(
          @infrastructure, 
          "InfrastructureComponent:#{component.id}",
          "Bootstrapping #{component.hostname} finished")
        component.update_status('FINISHED')

        # Check if bootstrap successful for all components
        @infrastructure.reload
        if @infrastructure.components_ready?
          @infrastructure.update_status('ACTIVE')
          @infrastructure.update_provisioning_status('FINISHED')
        end
        return true
      else
        Processor.produce_log(
          @infrastructure, 
          "InfrastructureComponent:#{component.id}",
          "Bootstrapping #{component.hostname} error",
          "#{res['error']}")
        component.update_status('BOOTSTRAP_ERROR', res['error'].to_s)
        @infrastructure.update_provisioning_status('BOOTSTRAP_ERROR')
        return false
      end
    end

    def generate_bootstrap_attributes(component, infrastructure_components)
      generator = BOOTSTRAP_ATTRIBUTES_GENERATORS[component.category]
      return {} unless generator.is_a? Class
      ChefHelper::GenericRoleAttributesGenerator.new.generate(
        generator.new(component, infrastructure_components))
    end
  end
end
