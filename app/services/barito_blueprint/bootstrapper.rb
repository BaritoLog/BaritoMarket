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

    def initialize(infrastructure, components, opts = {})
      @infrastructure = infrastructure
      @infrastructure_components = components
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
      @infrastructure.update_provisioning_status('BOOTSTRAP_FINISHED')
      return true
    end

    def bootstrap_instance!(component)
      Processor.produce_log(
        @infrastructure,
        "InfrastructureComponent:#{component.id}",
        "Bootstrapping #{component.hostname} started")
      component.update_status('BOOTSTRAP_STARTED')

      attrs = setup_bootstrap_attributes(component)

      if attrs.nil? || attrs.empty?
        Processor.produce_log(
          @infrastructure,
          "InfrastructureComponent:#{component.id}",
          "Bootstrapping #{component.hostname} error")
        component.update_status('BOOTSTRAP_ERROR')
        return false
      end

      Processor.produce_log(
        @infrastructure,
        "InfrastructureComponent:#{component.id}",
        "Bootstrapping #{component.hostname} finished")
      component.update_status('BOOTSTRAP_FINISHED')
      return true
    end

    def generate_bootstrap_attributes(component, infrastructure_components)
      generator = BOOTSTRAP_ATTRIBUTES_GENERATORS[component.component_type]
      return {} unless generator.is_a? Class
      ChefHelper::GenericRoleAttributesGenerator.new.generate(
        generator.new(component, infrastructure_components))
    end

    def setup_bootstrap_attributes(component)
      component.bootstrappers.each_with_index do |bootstrapper, idx|
        case bootstrapper["bootstrap_type"]
        when "chef-solo"
          if bootstrapper["bootstrap_attributes"]["run_list"].empty?
            # Fetch bootstrap attributes
            attrs = generate_bootstrap_attributes(
              component, @infrastructure_components)      
            component.bootstrappers[idx]["bootstrap_attributes"] = attrs
            component.save
            return attrs
          else
            return bootstrapper["bootstrap_attributes"]
          end
        else 
          return nil
        end
      end
    end
  end
end
