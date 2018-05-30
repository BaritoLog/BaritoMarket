class BlueprintProcessor
  attr_accessor :blueprint_hash, :nodes, :errors

  PROVISION_STATUS = [
    'UNPROCESSED',
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

    # Private keys
    @private_keys_dir       = (opts[:private_keys_dir] || "#{Rails.root}/config/private_keys")
    @private_key_name       = opts[:private_key_name]
    @username               = opts[:username]

    @blueprint_status = 'UNPROCESSED'
  end

  def process!
    # Set initial status
    if @blueprint_status == 'UNPROCESSED'
      @nodes = @blueprint_hash['nodes'].dup
      @nodes.each{ |node| node['provision_status'] = 'UNPROCESSED' }
    end
    @errors = []
    return (@blueprint_status = 'FAILED') unless provision_instances!
    return (@blueprint_status = 'FAILED') unless provision_apps!

    # Save consul host
    # TODO: @giosakti can be refactored
    app = App.find(@blueprint_hash['application_id'])
    consul_hosts = fetch_hosts_address_by(@nodes, 'type', 'consul')
    app.update!(consul: (consul_hosts || []).sample)

    return (@blueprint_status = 'SUCCESS')
  end

  def provision_instances!
    @nodes.each do |node|
      if node['provision_status'] == 'UNPROCESSED' || 
         node['provision_status'] == 'FAIL_INSTANCE_PROVISIONING'
        instance_provisioned, node = provision_instance!(node, private_key_name: @private_key_name)
        return false if !instance_provisioned
      end
    end
    return true
  end

  def provision_apps!
    @nodes.each do |node|
      if node['provision_status'] == 'INSTANCE_PROVISIONED' || 
         node['provision_status'] == 'FAIL_APPS_PROVISIONING'
        attrs = generate_instance_attributes(node, @nodes)
        apps_provisioned, node = provision_app!(
          node['instance_attributes']['host'] || "#{node['name']}",
          @username,
          node,
          private_keys_dir: @private_keys_dir,
          private_key_name: @private_key_name,
          attrs: attrs)
        return false if !apps_provisioned
      end
    end
    return true
  end

  def provision_instance!(node, opts = {})
    instance_provisioned = false
    res = @instance_provisioner.provision!(node['name'], key_pair_name: opts[:private_key_name])
    res['data'] ||= {}

    if res['success'] == true
      node['provision_status'] = 'INSTANCE_PROVISIONED'
      node['instance_attributes'] = {
        'host' => res['data']['host'],
        'key_pair_name' => res['data']['key_pair_name']
      }
      instance_provisioned = true
    else
      node['provision_status'] = 'FAIL_INSTANCE_PROVISIONING'
      @errors << { message: res['error'] }
    end

    [instance_provisioned, node]
  end

  def provision_app!(node_host, username, node, opts = {})
    apps_provisioned = false

    # Get private key file path
    private_key = nil
    if opts[:private_keys_dir] && opts[:private_key_name]
      private_key = File.join(opts[:private_keys_dir], opts[:private_key_name])
    end

    res = @apps_provisioner.provision!(
      node_host,
      username,
      private_key: private_key,
      attrs: opts[:attrs]
    )

    if res['success'] == true
      node['provision_status'] = 'APPS_PROVISIONED'
      node['apps_attributes'] = opts[:attrs]
      apps_provisioned = true
    else
      node['provision_status'] = 'FAIL_APPS_PROVISIONING'
      @errors << { message: res['error'], log: res['error_log'] }
    end

    [apps_provisioned, node]
  end

  def generate_instance_attributes(node, nodes)
    # Fetch consul hosts
    consul_hosts = fetch_hosts_address_by(nodes, 'type', 'consul')

    case node['type']
    when 'consul'
      ChefHelper::ConsulRoleAttributesGenerator.
        new(consul_hosts).
        generate
    when 'barito-flow-consumer'
      kafka_hosts = fetch_hosts_address_by(nodes, 'type', 'kafka')
      es_host = fetch_hosts_address_by(nodes, 'type', 'elasticsearch').first
      ChefHelper::BaritoFlowConsumerRoleAttributesGenerator.
        new(kafka_hosts, es_host).
        generate
    when 'barito-flow-producer'
      kafka_hosts = fetch_hosts_address_by(nodes, 'type', 'kafka')
      ChefHelper::BaritoFlowProducerRoleAttributesGenerator.
        new(kafka_hosts, consul_hosts).
        generate
    when 'elasticsearch'
      ChefHelper::ElasticsearchRoleAttributesGenerator.new.generate
    when 'kafka'
      zookeeper_hosts = fetch_hosts_address_by(nodes, 'type', 'zookeeper')
      kafka_hosts = fetch_hosts_address_by(nodes, 'type', 'kafka')
      ChefHelper::KafkaRoleAttributesGenerator.
        new(zookeeper_hosts, kafka_hosts).
        generate
    when 'kibana'
      es_host = fetch_hosts_address_by(nodes, 'type', 'elasticsearch').first
      ChefHelper::KibanaRoleAttributesGenerator.
        new(es_host).
        generate
    when 'yggdrasil'
      ChefHelper::YggdrasilRoleAttributesGenerator.
        new.
        generate
    when 'zookeeper'
      host = node['instance_attributes']['host'] || node['name']
      zookeeper_hosts = fetch_hosts_address_by(nodes, 'type', 'zookeeper')
      ChefHelper::ZookeeperRoleAttributesGenerator.
        new(host, zookeeper_hosts).
        generate
    else
      {}
    end
  end

  private
    def fetch_hosts_address_by(hosts, filter_type, filter)
      nodes.
        select{ |host| host[filter_type] == filter }.
        collect{ |host| host['instance_attributes']['host'] || host['name'] }
    end
end
