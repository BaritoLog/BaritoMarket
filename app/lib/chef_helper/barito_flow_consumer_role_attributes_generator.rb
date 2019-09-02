module ChefHelper
  class BaritoFlowConsumerRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      kafka_hosts = fetch_hosts_address_by(
        infrastructure_components, 'component_type', 'kafka')
      kafka_port = opts[:kafka_port] || 9092
      elasticsearch_hosts = fetch_hosts_address_by(
        infrastructure_components, 'component_type', 'elasticsearch')
      elasticsearch_port = opts[:elasticsearch_port] || 9200

      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'component_type', 'consul')
      @role_name = opts[:role_name] || 'barito-flow-consumer'
      @ipaddress = component.ipaddress
      consumer_template = ComponentTemplate.find_by(name: 'barito-flow-consumer')
      @consumer_attrs = get_bootstrap_attributes(consumer_template.bootstrappers)
      @push_metric_url = "#{Figaro.env.market_end_point}/api/increase_log_count"
      @kafka_hosts = bind_hosts_and_port(kafka_hosts, kafka_port)
      @elasticsearch_hosts = bind_hosts_and_port(elasticsearch_hosts, elasticsearch_port, "http")
    end

    def generate
      return {} if @consumer_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @consumer_attrs['barito-flow']['consumer']['env_vars']['BARITO_CONSUL_URL'] = "http://#{@consul_hosts.sample}:#{Figaro.env.default_consul_port}"
      @consumer_attrs['barito-flow']['consumer']['env_vars']['BARITO_KAFKA_BROKERS'] = @kafka_hosts
      @consumer_attrs['barito-flow']['consumer']['env_vars']['BARITO_ELASTICSEARCH_URLS'] = @elasticsearch_hosts
      @consumer_attrs['barito-flow']['consumer']['env_vars']['BARITO_PUSH_METRIC_URL'] = @push_metric_url

      @consumer_attrs['consul']['hosts'] = @consul_hosts
      @consumer_attrs['consul']['run_as_server'] = false
      @consumer_attrs['consul']['config']['consul.json']['bind_addr'] = @ipaddress
      @consumer_attrs['run_list'] = ["role[#{@role_name}]"]

      @consumer_attrs
    end
  end
end
