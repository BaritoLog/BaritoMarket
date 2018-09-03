class ProvisioningListener
  def consul_host_updated(component_id)
    component = InfrastructureComponent.find(component_id)
    if component.nil? or component.category != 'consul'
      return
    end
    infrastructure = component.infrastructure
    consul_host = component.ipaddress || component.hostname
    infrastructure.update!(
      consul_host: "#{consul_host}:#{Figaro.env.default_consul_port}")
  end
end
