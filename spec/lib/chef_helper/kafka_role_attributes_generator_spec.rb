require 'rails_helper'

module ChefHelper
  RSpec.describe KafkaRoleAttributesGenerator do
    before(:each) do
      @infrastructure = create(:infrastructure, cluster_name: 'test')
      @consul_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname:       'test-consul-01',
        component_type: 'consul',
        ipaddress:      '127.0.0.1'
      )
      @kafka_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname:       'test-kafka-01',
        component_type: 'kafka',
        ipaddress:      '127.0.0.2'
      )
      @zookeeper_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname:       'test-zookeeper-01',
        component_type: 'zookeeper',
        ipaddress:      '127.0.0.15'
      )
    end

    describe '#generate' do
      it 'should generate kafka attributes' do
        kafka_attributes = KafkaRoleAttributesGenerator.new(
          @kafka_component,
          @infrastructure.infrastructure_components
        )
        
        attrs = kafka_attributes.generate

        expect(attrs).to eq({
            "kafka"=>{
              "kafka"=>{"hosts"=>["kafka.service.consul"],"hosts_count"=>1}, 
              "zookeeper"=>{"hosts"=>["zookeeper.service.consul"]}
            },
            "consul"=>{
              "hosts"=>["#{@consul_component.ipaddress}"],
              "config"=>{
                "consul.json"=>{"bind_addr"=>"#{@kafka_component.ipaddress}"}
              },
              "run_as_server"=>false
            },
            "datadog"=>{
              "kafka"=>{
                "instances"=>[
                  {
                    "host"=>"localhost",
                    "port"=>8090,
                    "tags"=>[],
                    "cluster_name"=>""
                  }
                ]
              },
              "datadog_api_key"=>"",
              "datadog_hostname"=>""
            },
            "run_list"=>["role[kafka]"]
          }
        )
      end
    end
  end
end
