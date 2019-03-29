require 'rails_helper'

module ChefHelper
  RSpec.describe KibanaRoleAttributesGenerator do
    before(:each) do
      @infrastructure = create(:infrastructure, cluster_name: 'test')
      @consul_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname: 'test-consul-01',
        category: 'consul',
        ipaddress: '127.0.0.1'
      )
      @consumer_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname: 'test-barito-flow-consumer-01',
        category: 'barito-flow-consumer',
        ipaddress: '127.0.0.2'
      )
      @elastic_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname: 'test-elasticsearch-01',
        category: 'elasticsearch',
        ipaddress: '127.0.0.16'
      )
      create(:component_template,
        name: "kibana",
        component_attributes: {
          "consul":{
            "hosts":[], 
            "config":{"consul.json":{"bind_addr":""}}, 
            "run_as_server":false
          },
          "kibana":{
            "config":{
              "server.basePath":"", 
              "elasticsearch.url":""
            }, 
            "version":"6.3.0"
          }, 
          "run_list":[]
        }
      )
    end

    describe '#generate' do
      it 'should generate kibana attributes' do
        consumer_attributes = KibanaRoleAttributesGenerator.new(
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
            "kibana"=>{
              "config"=>{
                "server.basePath"=>"/#{@infrastructure.cluster_name}", 
                "elasticsearch.url"=>"http://#{@elastic_component.ipaddress}:9200"
              }, 
              "version"=>"6.3.0"
            },
            "run_list"=>["role[kibana]"]
          }
        )
      end
    end
  end
end