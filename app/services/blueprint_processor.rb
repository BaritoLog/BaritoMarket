class BlueprintProcessor
  attr_accessor :blueprint_hash, :nodes

  def initialize(blueprint_hash, opts = {})
    @blueprint_hash = blueprint_hash
    @nodes = []
    @sauron_host = (opts[:sauron_host] || '127.0.0.1:3000')
    @container_host = (opts[:container_host] || '127.0.0.1')
    @container_host_name = (opts[:container_host_name] || 'localhost')
    @status = 'UNPROCESSED'
  end

  def process!
    sauron_provisioner = SauronProvisioner.new(
      @sauron_host, @container_host, @container_host_name)

    # Process each node
    @blueprint_hash['nodes'].each do |node|
      node_state = node

      # Provision container
      res = sauron_provisioner.provision!(node['name'])
      res['data'] ||= {}

      # Act based on response
      if res['success'] == true
        node_state['provision_status'] = 'PROVISIONED'
        node_state['provision_attributes'] = {
          'ip_address' => res['data']['ip_address']
        }
      else
        node_state['provision_status'] = 'FAILED'
        @status = 'FAILED'
      end

      @nodes << node_state
    end

    @status = 'SUCCESS' unless @status == 'FAILED'
    return @status
  end
end
