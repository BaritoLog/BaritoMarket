module ChefHelper
  class BaritoFlowProducerRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @kafka_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'kafka')
      @kafka_port = opts[:kafka_port] || 9092
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @max_tps = TPS_CONFIG[component.infrastructure.capacity]['max_tps'] || 10
      @role_name = opts[:role_name] || 'barito-flow-producer'
      @ipaddress = component.ipaddress
    end

    def generate
      kafka_hosts_and_port = @kafka_hosts.
        map{ |kafka_host| "#{kafka_host}:#{@kafka_port}" }
      kafka_hosts_and_port = kafka_hosts_and_port.join(',')

      {
        'barito-flow' => {
          'producer' => {
            'version' => 'v0.11.1',
            'env_vars' => {
              'BARITO_PRODUCER_ADDRESS'     => ':8080',
              'BARITO_CONSUL_URL'           => "http://#{@consul_hosts.sample}:#{Figaro.env.default_consul_port}",
              'BARITO_CONSUL_KAFKA_NAME'    => 'kafka',
              'BARITO_KAFKA_BROKERS'        => kafka_hosts_and_port,
              'BARITO_KAFKA_PRODUCER_TOPIC' => 'barito-log',
              'BARITO_PRODUCER_MAX_TPS'     => @max_tps
            }
          }
        },
        'consul' => {
          'run_as_server' => false,
          'hosts' => @consul_hosts,
          'config' => {
            'consul.json' => {
              'bind_addr' => @ipaddress
            }
          }
        },
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
