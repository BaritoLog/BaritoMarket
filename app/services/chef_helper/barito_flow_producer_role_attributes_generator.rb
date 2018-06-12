module ChefHelper
  class BaritoFlowProducerRoleAttributesGenerator
    def initialize(kafka_hosts, consul_hosts, opts = {})
      @kafka_hosts  = kafka_hosts
      @kafka_port   = opts[:kafka_port] || 9092
      @consul_hosts = consul_hosts
      @tps_limit    = opts[:tps_limit] || 10
      @role_name    = opts[:role_name] || 'barito-flow-producer'
    end

    def generate
      kafka_hosts_and_port = @kafka_hosts.
        map{ |kafka_host| "#{kafka_host}:#{@kafka_port}" }
      kafka_hosts_and_port = kafka_hosts_and_port.join(',')

      {
        'barito-flow' => {
          'producer' => {
            'env_vars' => {
              'BARITO_PRODUCER_ADDRESS'     => ':8080',
              'BARITO_CONSUL_URL'           => "http://#{@consul_hosts.sample}:#{Figaro.env.default_consul_port}",
              'BARITO_CONSUL_KAFKA_NAME'    => 'kafka',
              'BARITO_KAFKA_BROKERS'        => kafka_hosts_and_port,
              'BARITO_KAFKA_PRODUCER_TOPIC' => 'barito-log',
              'BARITO_PRODUCER_MAX_TPS'     => @tps_limit
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
