require 'rails_helper'

module ChefHelper
  RSpec.describe BaritoFlowProducerRoleAttributesGenerator do
    before(:each) do
      @infrastructure = create(:infrastructure, cluster_name: 'test')
      @consul_component = create(:infrastructure_component,
        infrastructure: @infrastructure,
        hostname:       'test-consul-01',
        component_type: 'consul',
        ipaddress:      '127.0.0.1'
      )
      @producer_component = create(:infrastructure_component,
        infrastructure: @infrastructure,
        hostname:       'test-barito-flow-producer-01',
        component_type: 'barito-flow-producer',
        ipaddress:      '127.0.0.2'
      )
      @kafka_component_1 = create(:infrastructure_component,
        infrastructure: @infrastructure,
        hostname:       'test-kafka-01',
        component_type: 'kafka',
        ipaddress:      '127.0.0.15'
      )
    end

    describe '#generate' do
      it 'should generate producer attributes' do
        producer_attributes = BaritoFlowProducerRoleAttributesGenerator.new(
          @producer_component,
          @infrastructure.infrastructure_components
        )

        attrs = producer_attributes.generate

        expect(attrs).to eq({
            "consul"=>{
              "hosts"=>["#{@consul_component.ipaddress}"],
              "run_as_server"=>false
            },
            "run_list"=>["role[barito-flow-producer]"],
            "barito-flow"=>{
              "producer"=>{
                "version"=>"v0.11.8",
                "env_vars"=>{
                  "BARITO_CONSUL_URL"=>"http://consul.service.consul:8500",
                  "BARITO_KAFKA_BROKERS"=>"kafka.service.consul:9092",
                  "BARITO_PRODUCER_ADDRESS"=>":8080",
                  "BARITO_PRODUCER_MAX_TPS"=>@infrastructure.options['max_tps'],
                  "BARITO_CONSUL_KAFKA_NAME"=>"kafka",
                  "BARITO_KAFKA_PRODUCER_TOPIC"=>"barito-log",
                  "BARITO_PRODUCER_RATE_LIMIT_RESET_INTERVAL"=>10
                }
              }
            }
          }
        )
      end
    end
  end
end
