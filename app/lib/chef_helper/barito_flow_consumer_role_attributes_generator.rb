module ChefHelper
  class BaritoFlowConsumerRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      kafka_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'kafka')
      @kafka_port = opts[:kafka_port] || 9092
      @elasticsearch_host = fetch_hosts_address_by(
        infrastructure_components, 'category', 'elasticsearch')
      @elasticsearch_port = opts[:elasticsearch_port] || 9200
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @role_name = opts[:role_name] || 'barito-flow-consumer'
      @ipaddress = component.ipaddress
      consumer_template = ComponentTemplate.find_by(name: 'barito-flow-consumer')
      @consumer_attrs = consumer_template.component_attributes

      @kafka_hosts_and_port = kafka_hosts.
        map{ |kafka_host| "#{kafka_host}:#{@kafka_port}" }
      @kafka_hosts_and_port = @kafka_hosts_and_port.join(',')
      @elasticsearch_url = "http://#{@elasticsearch_host.first}:#{@elasticsearch_port}"
      @push_metric_url = "#{Figaro.env.market_end_point}/api/increase_log_count"
    end

    def generate
      return {} if @consumer_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @consumer_attrs['barito-flow']['consumer']['env_vars']['BARITO_CONSUL_URL'] = "http://#{@consul_hosts.sample}:#{Figaro.env.default_consul_port}"
      @consumer_attrs['barito-flow']['consumer']['env_vars']['BARITO_KAFKA_BROKERS'] = @kafka_hosts_and_port
      @consumer_attrs['barito-flow']['consumer']['env_vars']['BARITO_ELASTICSEARCH_URL'] = @elasticsearch_url
      @consumer_attrs['barito-flow']['consumer']['env_vars']['BARITO_PUSH_METRIC_URL'] = @push_metric_url

      @consumer_attrs['consul']['hosts'] = @consul_hosts
      @consumer_attrs['consul']['run_as_server'] = false
      @consumer_attrs['consul']['config']['consul.json']['bind_addr'] = @ipaddress
      @consumer_attrs['run_list'] = ["role[#{@role_name}]"]

      @consumer_attrs
    end
  end
end
