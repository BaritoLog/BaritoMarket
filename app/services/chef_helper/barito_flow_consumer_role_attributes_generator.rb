module ChefHelper
  class BaritoFlowConsumerRoleAttributesGenerator
    def initialize(kafka_hosts, elasticsearch_host, consul_hosts, opts = {})
      @kafka_hosts = kafka_hosts
      @kafka_port = opts[:kafka_port] || 9092
      @elasticsearch_host = elasticsearch_host
      @elasticsearch_port = opts[:elasticsearch_port] || 9200
      @consul_hosts = consul_hosts
      @role_name = opts[:role_name] || 'barito-flow-consumer'
    end

    def generate
      kafka_hosts_and_port = @kafka_hosts.
        map{ |kafka_host| "#{kafka_host}:#{@kafka_port}" }.
        join(',')
      elasticsearch_url = "http://#{@elasticsearch_host}:#{@elasticsearch_port}"

      {
        'barito-flow' => {
          'consumer' => {
            'env_vars' => {
              'BARITO_FORWARDER_KAFKA_BROKERS' => kafka_hosts_and_port,
              'BARITO_FORWARDER_KAFKA_CONSUMER_GROUP_ID' => 'barito-group',
              'BARITO_FORWARDER_KAFKA_CONSUMER_TOPIC' => 'barito-log',
              'BARITO_FORWARDER_ELASTICSEARCH_URL' => elasticsearch_url
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
