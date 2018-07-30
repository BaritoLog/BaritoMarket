class BlueprintProcessor
  attr_accessor :blueprint_hash, :infrastructure_components, :errors, :infrastructure

  def initialize(blueprint_hash=nil, opts = {})
    @blueprint_hash = blueprint_hash
    @infrastructure_components = []
    @errors = []

    if @blueprint_hash
      @infrastructure = Infrastructure.find(@blueprint_hash['infrastructure_id'])
    else
      @infrastructure = Infrastructure.find(opts[:infrastructure_id])
    end

    # Initialize Provisioner
    @sauron_host          = (opts[:sauron_host] || '127.0.0.1:3000')
    @provisioner          = SauronProvisioner.new(@sauron_host)

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
    # Reset errors
    @errors = []

    @blueprint_hash['nodes'].each_with_index do |node, seq|
      @infrastructure_components << @infrastructure.add_component(
        node, seq + 1)
    end

    # Provision instances
    Rails.logger.info "Infrastructure:#{@infrastructure.id} -- Provisioning started"
    if provision_instances!
      @infrastructure.update_provisioning_status('PROVISIONING_STARTED')
      Rails.logger.info "Infrastructure:#{@infrastructure.id} -- Provisioning finished"
    else
      @infrastructure.update_provisioning_status('PROVISIONING_ERROR')
      Rails.logger.error "Infrastructure:#{@infrastructure.id} -- Provisioning error: #{@errors}"
      return false
    end

    # Make sure all infrastructure components have ipaddress
    return false unless infrastructure_components_complete!

    # Bootstrap instances
    return false unless bootstrap_instances!

    # Save consul host
    consul_hosts = fetch_hosts_address_by(@infrastructure_components, 'category', 'consul')
    consul_host = (consul_hosts || []).sample
    @infrastructure.update!(consul_host: "#{consul_host}:#{Figaro.env.default_consul_port}")

    return true
  end
  def provision_instances!
    @infrastructure_components.each do |component|
      Rails.logger.info "Infrastructure:#{@infrastructure.id} -- InfrastructureComponent:#{component.id} -- Provisioning #{component.hostname}"
      return false unless provision_instance!(
        component,
        private_key_name: @private_key_name
      )
    end
    return true
  end

  def provision_instance!(component, opts = {})
    success = false

    # Execute provisioning
    res = @provisioner.provision!(component.hostname)
    Rails.logger.info "Infrastructure:#{@infrastructure.id} -- InfrastructureComponent:#{component.id} -- Provisioning #{component.hostname} -- #{res}"

    if res['success'] == "true"
      component.update_status('PROVISIONING_STARTED')
      success = true
    else
      @errors << { message: res['error'] }
      component.update_status('PROVISIONING_ERROR', @errors.to_s)
    end

    return success
  end

  def infrastructure_components_complete!(infrastructure_components=nil)
    count = 0
    is_provisioning_finished = !@infrastructure_components.any?{|component| !component.ipaddress}
    while !is_provisioning_finished && DateTime.current < DateTime.current+5.minutes
      sleep(Figaro.env.wait_interval.to_i) unless Rails.env.test?

      @infrastructure_components.each do |component|
        Rails.logger.info "Infrastructure:#{@infrastructure.id} -- InfrastructureComponent:#{component.id} -- Check IP Address #{component.hostname}"
        check_ipaddress!(component) unless component.ipaddress
      end
      is_provisioning_finished = !@infrastructure_components.any?{|component| !component.ipaddress}
      count += 1
    end
    return false unless is_provisioning_finished
    return true
  end

  def check_ipaddress!(component)
    show_res = @provisioner.show_container(component.hostname)
    ipaddress = show_res.dig('data', 'ipaddress')

    unless ipaddress
      component.update_status('PROVISIONING_ERROR', @errors.to_s)
      @infrastructure.update_provisioning_status('PROVISIONING_ERROR')
    else
      component.update(ipaddress: ipaddress)
      component.update_status('PROVISIONING_FINISHED')
      @infrastructure.update_provisioning_status('PROVISIONING_FINISHED')
    end
  end

  def bootstrap_instances!(infrastructure_components=nil, seq=1)
    @infrastructure.update_provisioning_status('BOOTSTRAP_STARTED')
    @infrastructure_components = infrastructure_components if infrastructure_components

    @infrastructure_components.each do |component|
      # return false unless check_ipaddress!(component)
      if component.sequence >= seq
        Rails.logger.info "Infrastructure:#{@infrastructure.id} -- InfrastructureComponent:#{component.id} -- Bootstrapping #{component.hostname}"
        attrs = generate_bootstrap_attributes(component, @infrastructure_components)
        bootstrap_res = bootstrap_instance!(
            component,
            @username,
            private_keys_dir: @private_keys_dir,
            private_key_name: @private_key_name,
            attrs: attrs
          )

        unless bootstrap_res
          @infrastructure.update_provisioning_status('BOOTSTRAP_ERROR')
          Rails.logger.error "Infrastructure:#{@infrastructure.id} -- Bootstrap error: #{@errors}"
          return false
        end
      end
    end

    @infrastructure.update_provisioning_status('FINISHED')
    Rails.logger.info "Infrastructure:#{@infrastructure.id} -- Bootstrap finished"
    return true
  end

  def bootstrap_instance!(component, username, opts = {})
    success = false

    component.update_status('BOOTSTRAP_STARTED')
    # Get private key file path
    private_key = nil
    if opts[:private_keys_dir] && opts[:private_key_name]
      private_key = File.join(opts[:private_keys_dir], opts[:private_key_name])
    end
    res = @bootstrapper.bootstrap!(
      component.hostname,
      component.ipaddress,
      username,
      private_key: private_key,
      attrs: opts[:attrs]
    )
    Rails.logger.info "Infrastructure:#{@infrastructure.id} -- InfrastructureComponent:#{component.id} -- Bootstrapping #{component.hostname} -- #{res}"

    if res['success'] == true
      success = true
      component.update_attribute(:bootstrap_attributes, opts[:attrs])
      component.update_status('FINISHED')
    else
      @errors << { message: res['error'], log: res['error_log'] }
      component.update_status('BOOTSTRAP_ERROR', @errors.to_s)
    end

    return success
  end

  def generate_bootstrap_attributes(component, infrastructure_components)
    # Fetch consul hosts
    consul_hosts = fetch_hosts_address_by(infrastructure_components, 'category', 'consul')

    case component.category
    when 'consul'
      ChefHelper::ConsulRoleAttributesGenerator.
        new(consul_hosts).
        generate
    when 'barito-flow-consumer'
      kafka_hosts = fetch_hosts_address_by(infrastructure_components, 'category', 'kafka')
      es_host = fetch_hosts_address_by(infrastructure_components, 'category', 'elasticsearch').first
      ChefHelper::BaritoFlowConsumerRoleAttributesGenerator.
        new(kafka_hosts, es_host, consul_hosts).
        generate
    when 'barito-flow-producer'
      kafka_hosts = fetch_hosts_address_by(infrastructure_components, 'category', 'kafka')
      max_tps = TPS_CONFIG[@infrastructure.capacity]['max_tps']
      ChefHelper::BaritoFlowProducerRoleAttributesGenerator.
        new(kafka_hosts, consul_hosts, max_tps: max_tps).
        generate
    when 'elasticsearch'
      ChefHelper::ElasticsearchRoleAttributesGenerator.
        new(consul_hosts).
        generate
    when 'kafka'
      zookeeper_hosts = fetch_hosts_address_by(infrastructure_components, 'category', 'zookeeper')
      kafka_hosts = fetch_hosts_address_by(infrastructure_components, 'category', 'kafka')
      ChefHelper::KafkaRoleAttributesGenerator.
        new(zookeeper_hosts, kafka_hosts, consul_hosts).
        generate
    when 'kibana'
      es_host = fetch_hosts_address_by(infrastructure_components, 'category', 'elasticsearch').first
      ChefHelper::KibanaRoleAttributesGenerator.
        new(es_host, consul_hosts).
        generate
    when 'yggdrasil'
      ChefHelper::YggdrasilRoleAttributesGenerator.
        new.
        generate
    when 'zookeeper'
      host = component.ipaddress || component.hostname
      zookeeper_hosts = fetch_hosts_address_by(infrastructure_components, 'category', 'zookeeper')
      ChefHelper::ZookeeperRoleAttributesGenerator.
        new(host, zookeeper_hosts, consul_hosts).
        generate
    else
      {}
    end
  end

  private
    def fetch_hosts_address_by(infrastructure_components, filter_type, filter)
      infrastructure_components.
        select{ |component| component.send(filter_type.to_sym) == filter }.
        collect{ |component| component.ipaddress || component.hostname }
    end
end
