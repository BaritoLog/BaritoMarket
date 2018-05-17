class BlueprintProcessor
  attr_accessor :blueprint_hash, :nodes

  def initialize(blueprint_hash, opts = {})
    @blueprint_hash = blueprint_hash
    @nodes = []
    @container_host_ip = (opts[:container_host_ip] || '127.0.0.1')
    @container_host_name = (opts[:container_host_name] || 'localhost')
    @status = 'SUCCESS'
  end

  def process!
    sauron_provisioner = SauronProvisioner.new(@container_host_ip, @container_host_name)
    @blueprint_hash['nodes'].each do |node|
      node_state = node

      response = sauron_provisioner.provision!(node['name'])
      if response['success'] == 'true'
        node_state['provision_status'] = 'PROVISIONED'
        node_state['provision_attributes'] = {
          'ip_address' => response['ip_address']
        }
      else
        node_state['provision_status'] = 'FAILED'
        @status = 'FAILED'
      end

      @nodes << node_state
    end

    return @status
  end
end
