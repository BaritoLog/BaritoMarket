class BlueprintProcessor
  attr_accessor :blueprint_hash, :nodes, :errors, :barito_app

  def initialize(blueprint_hash, opts = {})
    @blueprint_hash = blueprint_hash
    @nodes = []
    @errors = []
    @barito_app = BaritoApp.find(@blueprint_hash['application_id'])

    # Initialize Provisioner
    @sauron_host          = (opts[:sauron_host] || '127.0.0.1:3000')
    @container_host       = (opts[:container_host] || '127.0.0.1')
    @container_host_name  = (opts[:container_host_name] || 'localhost')
    @provisioner          = SauronProvisioner.new(
      @sauron_host, 
      @container_host, 
      @container_host_name
    )

    # Initialize Bootstrapper
    @chef_repo_dir        = (opts[:chef_repo_dir] || '/opt/chef-repo')
    @bootstrapper         = ChefSoloBootstrapper.new(@chef_repo_dir)

    # Private keys
    @private_keys_dir     = (opts[:private_keys_dir] || 
      "#{Rails.root}/config/private_keys")
    @private_key_name     = opts[:private_key_name]
    @username             = opts[:username]
  end

  def process!
    # Reset nodes and errors
    @nodes = @blueprint_hash['nodes'].dup
    @errors = []

    # Provision instances
    @barito_app.update_setup_status('PROVISIONING_STARTED')
    Rails.logger.info "App:#{@barito_app.id} -- Provisioning started"
    if provision_instances!
      @barito_app.update_setup_status('PROVISIONING_FINISHED')
      Rails.logger.info "App:#{@barito_app.id} -- Provisioning finished"
    else
      @barito_app.update_setup_status('PROVISIONING_ERROR')
      Rails.logger.error "App:#{@barito_app.id} -- Provisioning error: #{@errors}"
      return false
    end

    # Bootstrap instances
    @barito_app.update_setup_status('BOOTSTRAP_STARTED')
    Rails.logger.info "App:#{@barito_app.id} -- Bootstrap started"
    if bootstrap_instances!
      @barito_app.update_setup_status('FINISHED')
      Rails.logger.info "App:#{@barito_app.id} -- Bootstrap finished"
    else
      @barito_app.update_setup_status('BOOTSTRAP_ERROR')
      Rails.logger.error "App:#{@barito_app.id} -- Bootstrap error: #{@errors}"
      return false
    end

    # Save consul host
    consul_hosts = fetch_hosts_address_by(@nodes, 'type', 'consul')
    consul_host = (consul_hosts || []).sample
    @barito_app.update!(consul_host: "#{consul_host}:#{Figaro.env.default_consul_port}")

    return true
  end

  def provision_instances!
    @nodes.each do |node|
      Rails.logger.info "App:#{@barito_app.id} -- Provisioning #{node['name']}"
      return false unless provision_instance!(
        node, 
        private_key_name: @private_key_name
      )
    end
    return true
  end

  def provision_instance!(node, opts = {})
    success = false

    # Execute provisioning
    res = @provisioner.provision!(
      node['name'],
      key_pair_name: opts[:private_key_name]
    )
    Rails.logger.info "App:#{@barito_app.id} -- Provisioning #{node['name']} -- #{res}"

    if res['success'] == true
      node['instance_attributes'] = {
        'host_ipaddress' => res.dig('data', 'host_ipaddress'),
        'key_pair_name' => res.dig('data', 'key_pair_name')
      }
      success = true
    else
      @errors << { message: res['error'] }
    end

    return success
  end

  def bootstrap_instances!
    @nodes.each do |node|
      Rails.logger.info "App:#{@barito_app.id} -- Bootstrapping #{node['name']}"
      attrs = generate_bootstrap_attributes(node, @nodes)
      return false unless bootstrap_instance!(
        node,
        @username,
        private_keys_dir: @private_keys_dir,
        private_key_name: @private_key_name,
        attrs: attrs
      )
    end
    return true
  end

  def bootstrap_instance!(node, username, opts = {})
    success = false

    # Get private key file path
    private_key = nil
    if opts[:private_keys_dir] && opts[:private_key_name]
      private_key = File.join(opts[:private_keys_dir], opts[:private_key_name])
    end

    res = @bootstrapper.bootstrap!(
      node['name'],
      node['instance_attributes']['host_ipaddress'],
      username,
      private_key: private_key,
      attrs: opts[:attrs]
    )
    Rails.logger.info "App:#{@barito_app.id} -- Bootstrapping #{node['name']} -- #{res}"

    if res['success'] == true
      node['bootstrap_attributes'] = opts[:attrs]
      success = true
    else
      @errors << { message: res['error'], log: res['error_log'] }
    end

    return success
  end

  def generate_bootstrap_attributes(node, nodes)
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
        new(@barito_app.secret_key, kafka_hosts, es_host, consul_hosts).
        generate
    when 'barito-flow-producer'
      kafka_hosts = fetch_hosts_address_by(nodes, 'type', 'kafka')
      config = YAML.load_file("#{Rails.root}/config/tps_config.yml")[Rails.env]
      tps_limit = config[@barito_app.tps_config]['tps_limit']
      ChefHelper::BaritoFlowProducerRoleAttributesGenerator.
        new(kafka_hosts, consul_hosts, tps_limit: tps_limit).
        generate
    when 'elasticsearch'
      ChefHelper::ElasticsearchRoleAttributesGenerator.
        new(consul_hosts).
        generate
    when 'kafka'
      zookeeper_hosts = fetch_hosts_address_by(nodes, 'type', 'zookeeper')
      kafka_hosts = fetch_hosts_address_by(nodes, 'type', 'kafka')
      ChefHelper::KafkaRoleAttributesGenerator.
        new(zookeeper_hosts, kafka_hosts, consul_hosts).
        generate
    when 'kibana'
      es_host = fetch_hosts_address_by(nodes, 'type', 'elasticsearch').first
      ChefHelper::KibanaRoleAttributesGenerator.
        new(es_host, consul_hosts).
        generate
    when 'yggdrasil'
      ChefHelper::YggdrasilRoleAttributesGenerator.
        new.
        generate
    when 'zookeeper'
      host = node['instance_attributes']['host_ipaddress'] || node['name']
      zookeeper_hosts = fetch_hosts_address_by(nodes, 'type', 'zookeeper')
      ChefHelper::ZookeeperRoleAttributesGenerator.
        new(host, zookeeper_hosts, consul_hosts).
        generate
    else
      {}
    end
  end

  private
    def fetch_hosts_address_by(hosts, filter_type, filter)
      nodes.
        select{ |host| host[filter_type] == filter }.
        collect{ |host| host['instance_attributes']['host_ipaddress'] || host['name'] }
    end
end
