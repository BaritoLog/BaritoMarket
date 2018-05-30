module ChefHelper
  class BaritoFlowProducerRoleAttributesGenerator
    def initialize(kafka_hosts, consul_hosts, opts = {})
      @kafka_hosts = kafka_hosts
      @kafka_port = opts[:kafka_port] || 9092
      @consul_hosts = consul_hosts
      @role_name = opts[:role_name] || 'barito-flow-producer'
    end

    def generate
      kafka_hosts_and_port = @kafka_hosts.
        map{ |kafka_host| "#{kafka_host}:#{@kafka_port}" }.
        join(',')

      {
        'barito-flow' => {
          'producer' => {
            'env_vars' => {
              'BARITO_RECEIVER_KAFKA_BROKERS' => kafka_hosts_and_port,
              'BARITO_RECEIVER_KAFKA_TOPIC' => 'barito-log'
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
