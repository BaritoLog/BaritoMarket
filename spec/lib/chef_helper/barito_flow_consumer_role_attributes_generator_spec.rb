require 'rails_helper'

module ChefHelper
  RSpec.describe BaritoFlowConsumerRoleAttributesGenerator do
    before(:each) do
      @infrastructure = create(:infrastructure, cluster_name: 'test')
      @consul_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname:       'test-consul-01',
        component_type: 'consul',
        ipaddress:      '127.0.0.1'
      )
      @consumer_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname:       'test-barito-flow-consumer-01',
        component_type: 'barito-flow-consumer',
        ipaddress:      '127.0.0.2'
      )
      @kafka_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname:       'test-kafka-01',
        component_type: 'kafka',
        ipaddress:      '127.0.0.15'
      )
      @elastic_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname:       'test-elasticsearch-01',
        component_type: 'elasticsearch',
        ipaddress:      '127.0.0.16'
      )
    end

    describe '#generate' do
      it 'should generate consumer attributes' do
        consumer_attributes = BaritoFlowConsumerRoleAttributesGenerator.new(
          @consumer_component,
          @infrastructure.infrastructure_components
        )
        
        attrs = consumer_attributes.generate

        expect(attrs).to eq({
            "consul"=>{
              "hosts"=>["#{@consul_component.ipaddress}"],
              "config"=>{
                "consul.json"=>{"bind_addr"=>"#{@consumer_component.ipaddress}"}
              },
              "run_as_server"=>false
            },
            "run_list"=>["role[barito-flow-consumer]"],
            "barito-flow"=>{
              "consumer"=>{
                "version"=>"v0.11.8",
                "env_vars"=>{
                  "BARITO_CONSUL_URL"=>"http://#{@consul_component.ipaddress}:8500",
                  "BARITO_CONSUL_KAFKA_NAME"=>"kafka", 
                  "BARITO_CONSUL_ELASTICSEARCH_NAME"=>"elasticsearch",
                  "BARITO_KAFKA_BROKERS"=>"#{@kafka_component.ipaddress}:9092", 
                  "BARITO_KAFKA_GROUP_ID"=>"barito-group", 
                  "BARITO_KAFKA_CONSUMER_TOPICS"=>"barito-log", 
                  "BARITO_ELASTICSEARCH_URL"=>"http://#{@elastic_component.ipaddress}:9200", 
                  "BARITO_PUSH_METRIC_URL"=>"#{Figaro.env.market_end_point}/api/increase_log_count"
                }
              }
            }
          }
        )
      end
    end
  end
end

