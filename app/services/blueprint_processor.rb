class BlueprintProcessor
  attr_accessor :blueprint_hash, :nodes

  PROVISION_STATUS = [
    'FAIL_INSTANCE_PROVISIONING', 
    'INSTANCE_PROVISIONED', 
    'FAIL_APPS_PROVISIONING', 
    'ALL_PROVISIONED'
  ]

  def initialize(blueprint_hash, opts = {})
    @blueprint_hash = blueprint_hash
    @nodes = []

    # Initialize Container Provisioner
    @sauron_host            = (opts[:sauron_host] || '127.0.0.1:3000')
    @container_host         = (opts[:container_host] || '127.0.0.1')
    @container_host_name    = (opts[:container_host_name] || 'localhost')
    @access_key             = opts[:access_key]
    @container_provisioner  = SauronProvisioner.new(
      @sauron_host, @container_host, @container_host_name)

    @blueprint_status = 'UNPROCESSED'
  end

  def process!
    @blueprint_hash['nodes'].each do |node|
      node_state = node.dup

      # Provision container
      exit_status, node_state = provisioner_container!(
        node, node_state, access_key: @access_key)
      @blueprint_status = 'FAILED' unless exit_status == false

      @nodes << node_state
    end

    @blueprint_status = 'SUCCESS' unless @blueprint_status == 'FAILED'
    return @blueprint_status
  end

  def provisioner_container!(node, node_state, opts = {})
    exit_status = false
    res = @container_provisioner.provision!(node['name'], access_key: opts[:access_key])
    res['data'] ||= {}

    if res['success'] == true
      node_state['provision_status'] = 'INSTANCE_PROVISIONED'
      node_state['provision_attributes'] = {
        'ip_address' => res['data']['ip_address'],
        'access_key' => res['data']['access_key']
      }
      exit_status = true
    else
      node_state['provision_status'] = 'FAIL_INSTANCE_PROVISIONING'
    end

    [exit_status, node_state]
  end
end
