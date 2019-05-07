class ProvisioningListener
  def instance_provisioned(infrastructure_component_id)
    component = InfrastructureComponent.find(infrastructure_component_id)
    if component.nil? or component.component_type != 'consul'
      return
    end
    infrastructure = component.infrastructure
    consul_host = component.ipaddress || component.hostname
    infrastructure.update!(
      consul_host: "#{consul_host}:#{Figaro.env.default_consul_port}")
  end
end
