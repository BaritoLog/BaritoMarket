module ChefHelper
  class BaritoFlowConsumerRoleAttributesGenerator < GenericRoleAttributesGenerator
    def initialize(component, infrastructure_components, opts = {})
      @kafka_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'kafka')
      @kafka_port = opts[:kafka_port] || 9092
      @elasticsearch_host = fetch_hosts_address_by(
        infrastructure_components, 'category', 'elasticsearch')
      @elasticsearch_port = opts[:elasticsearch_port] || 9200
      @consul_hosts = fetch_hosts_address_by(
        infrastructure_components, 'category', 'consul')
      @role_name = opts[:role_name] || 'barito-flow-consumer'
    end

    def generate
      kafka_hosts_and_port = @kafka_hosts.
        map{ |kafka_host| "#{kafka_host}:#{@kafka_port}" }
      kafka_hosts_and_port = kafka_hosts_and_port.join(',')
      elasticsearch_url = "http://#{@elasticsearch_host.first}:#{@elasticsearch_port}"
      push_metric_url = "#{Figaro.env.market_end_point}/api/increase_log_count"

      {
        'barito-flow' => {
          'consumer' => {
            'version' => 'v0.8.3',
            'env_vars' => {
              'BARITO_CONSUL_URL'                 => "http://#{@consul_hosts.sample}:#{Figaro.env.default_consul_port}",
              'BARITO_CONSUL_KAFKA_NAME'          => 'kafka',
              'BARITO_CONSUL_ELASTICSEARCH_NAME'  => 'elasticsearch',
              'BARITO_KAFKA_BROKERS'              => kafka_hosts_and_port,
              'BARITO_KAFKA_GROUP_ID'             => 'barito-group',
              'BARITO_KAFKA_CONSUMER_TOPICS'      => 'barito-log',
              'BARITO_ELASTICSEARCH_URL'          => elasticsearch_url,
              'BARITO_PUSH_METRIC_URL'            => push_metric_url,
            }
          }
        },
        'consul' => {
          'run_as_server' => false,
          'hosts' => @consul_hosts
        },
        'run_list' => ["role[#{@role_name}]"]
      }
    end
  end
end
