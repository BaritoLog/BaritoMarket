module ChefHelper
  class BaritoFlowProducerRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      kafka_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'kafka')
      @kafka_port = opts[:kafka_port] || 9092
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @max_tps = component.infrastructure.cluster_template.try(:max_tps) || TPS_CONFIG[component.infrastructure.capacity]['max_tps'] || 10
      @role_name = opts[:role_name] || 'barito-flow-producer'
      @ipaddress = component.ipaddress
      producer_property = ComponentTemplate.find_by(name: 'barito-flow-producer')
      @producer_attrs = producer_property.component_attributes
      kafka_hosts_and_port = kafka_hosts.
        map{ |kafka_host| "#{kafka_host}:#{@kafka_port}" }
      @kafka_hosts_and_port = kafka_hosts_and_port.join(',')
    end

    def generate
      return {} if @producer_attrs.nil?
      return update_attrs
    end

    def update_attrs
      @producer_attrs['barito-flow']['producer']['version'] = 'v0.11.8'
      @producer_attrs['barito-flow']['producer']['env_vars'] = {
        'BARITO_PRODUCER_ADDRESS'     => ':8080',
        'BARITO_CONSUL_URL'           => "http://#{@consul_hosts.sample}:#{Figaro.env.default_consul_port}",
        'BARITO_CONSUL_KAFKA_NAME'    => 'kafka',
        'BARITO_KAFKA_BROKERS'        => @kafka_hosts_and_port,
        'BARITO_KAFKA_PRODUCER_TOPIC' => 'barito-log',
        'BARITO_PRODUCER_MAX_TPS'     => @max_tps,
        'BARITO_PRODUCER_RATE_LIMIT_RESET_INTERVAL' => 10,
      }
      @producer_attrs['consul']['hosts'] = @consul_hosts
      @producer_attrs['consul']['run_as_server'] = false
      @producer_attrs['consul']['config']['consul.json']['bind_addr'] = @ipaddress
      @producer_attrs['run_list'] = ["role[#{@role_name}]"]

      @producer_attrs
    end
  end
end
