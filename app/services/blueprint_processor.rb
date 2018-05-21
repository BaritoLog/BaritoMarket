class BlueprintProcessor
  attr_accessor :blueprint_hash, :nodes, :errors

  PROVISION_STATUS = [
    'FAIL_INSTANCE_PROVISIONING', 
    'INSTANCE_PROVISIONED', 
    'FAIL_APPS_PROVISIONING', 
    'APPS_PROVISIONED'
  ]

  def initialize(blueprint_hash, opts = {})
    @blueprint_hash = blueprint_hash
    @nodes = []
    @errors = []

    # Initialize Instance Provisioner
    @sauron_host            = (opts[:sauron_host] || '127.0.0.1:3000')
    @container_host         = (opts[:container_host] || '127.0.0.1')
    @container_host_name    = (opts[:container_host_name] || 'localhost')
    @instance_provisioner   = SauronProvisioner.new(
      @sauron_host, @container_host, @container_host_name)

    # Initialize Apps Provisioner
    @chef_repo_dir          = (opts[:chef_repo_dir] || '/opt/chef-repo')
    @apps_provisioner       = ChefSoloProvisioner.new(@chef_repo_dir)

    # Access keys
    @access_keys_dir        = (opts[:access_keys_dir] || "#{Rails.root}/config/access_keys")
    @access_key             = opts[:access_key]
    @username               = opts[:username]

    @blueprint_status = 'UNPROCESSED'
  end

  def process!
    @blueprint_hash['nodes'].each do |node|
      node_state = node.dup

      # Provision instance
      instance_provisioned, node_state = provision_instance!(
        node_state, access_key: @access_key)

      # Provision apps within instance
      if instance_provisioned == true
        attrs = generate_instance_attributes(node_state)
        apps_provisioned, node_state = provision_apps!(
          node_state['instance_attributes']['ip_address'] || "#{node_state['name']}",
          @username,
          node_state,
          access_keys_dir: @access_keys_dir,
          access_key: @access_key,
          attrs: attrs)
      end

      @nodes << node_state
      @blueprint_status = 'FAILED' unless (instance_provisioned && apps_provisioned)
    end

    @blueprint_status = 'SUCCESS' unless @blueprint_status == 'FAILED'
    return @blueprint_status
  end

  def provision_instance!(node_state, opts = {})
    instance_provisioned = false
    res = @instance_provisioner.provision!(node_state['name'], access_key: opts[:access_key])
    res['data'] ||= {}

    if res['success'] == true
      node_state['provision_status'] = 'INSTANCE_PROVISIONED'
      node_state['instance_attributes'] = {
        'ip_address' => res['data']['ip_address'],
        'access_key' => res['data']['access_key']
      }
      instance_provisioned = true
    else
      node_state['provision_status'] = 'FAIL_INSTANCE_PROVISIONING'
    end

    [instance_provisioned, node_state]
  end

  def provision_apps!(node_host, username, node_state, opts = {})
    apps_provisioned = false

    private_key = nil
    if opts[:access_keys_dir] && opts[:access_key]
      private_key = File.join(opts[:access_keys_dir], opts[:access_key])
    end

    res = @apps_provisioner.provision!(
      node_host,
      username,
      private_key: private_key,
      attrs: opts[:attrs]
    )

    if res['success'] == true
      node_state['provision_status'] = 'APPS_PROVISIONED'
      node_state['apps_attributes'] = opts[:attrs]
      apps_provisioned = true
    else
      node_state['provision_status'] = 'FAIL_APPS_PROVISIONING'
      @errors << { message: res['error'], log: res['error_log'] }
    end

    [apps_provisioned, node_state]
  end

  # TODO: @giosakti should get these attributes from templates
  def generate_instance_attributes(node_state)
    case node_state['type']
    when 'consul'
      { 'run_list' => ['role[consul]'] }
    when 'elasticsearch'
      { 'run_list' => ['role[elasticsearch]'] }
    when 'kafka'
      { 'run_list' => ['role[kafka]'] }
    when 'kibana'
      { 'run_list' => ['role[kibana]'] }
    when 'yggdrasil'
      { 'run_list' => ['role[yggdrasil]'] }
    when 'zookeeper'
      { 'run_list' => ['role[zookeeper]'] }
    else
      {}
    end
  end
end
