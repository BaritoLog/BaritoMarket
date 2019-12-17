require 'rails_helper'

module ChefHelper
  RSpec.describe ZookeeperRoleAttributesGenerator do
    before(:each) do
      @infrastructure = create(:infrastructure, cluster_name: 'test')
      @consul_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname:       'test-consul-01',
        component_type: 'consul',
        ipaddress:      '127.0.0.1'
      )
      @zookeeper_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname:       'test-zookeeper-01',
        component_type: 'zookeeper',
        ipaddress:      '127.0.0.15'
      )
    end

    describe '#generate' do
      it 'should generate zookeeper attributes' do
        zookeeper_attributes = ZookeeperRoleAttributesGenerator.new(
          @zookeeper_component,
          @infrastructure.infrastructure_components
        )
        
        attrs = zookeeper_attributes.generate

        expect(attrs).to eq({
            "consul"=>{
              "hosts"=>["#{@consul_component.ipaddress}"], 
              "config"=>{
                "consul.json"=>{"bind_addr"=>"#{@zookeeper_component.ipaddress}"}
              }, 
              "run_as_server"=>false
            }, 
            "datadog"=>{
              "zk"=>{
                "instances"=>[
                  {
                    "host"=>"localhost", 
                    "port"=>2181, 
                    "tags"=>[], 
                    "cluster_name"=>""
                  }
                ]
              },
              "datadog_api_key"=>"",
              "datadog_hostname"=>""
            },
            "run_list"=>["role[zookeeper]"], 
            "zookeeper"=>{
              "hosts"=>["zookeeper.service.consul"], 
              "my_id"=>1
            }
          }
        )
      end
    end
  end
end
