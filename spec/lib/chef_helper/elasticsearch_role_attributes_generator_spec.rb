require 'rails_helper'

module ChefHelper
  RSpec.describe ElasticsearchRoleAttributesGenerator do
    before(:each) do
      @infrastructure = create(:infrastructure, cluster_name: 'test')
      @consul_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname: 'test-consul-01',
        category: 'consul',
        ipaddress: '127.0.0.1'
      )
      @elastic_component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname: 'test-elastic-01',
        category: 'elastic',
        ipaddress: '127.0.0.2'
      )
      create(:component_template,
        name: 'elasticsearch', 
        component_attributes: {
          "consul":{
            "hosts":[], 
            "config":{"consul.json":{"bind_addr":""}}, 
            "run_as_server":false
          }, 
          "datadog":{
            "elastic":{
              "instances":[{"url":"", "tags":[]}]
            }, 
            "datadog_api_key":"", 
            "datadog_hostname":""
          }, 
          "run_list":[], 
          "elasticsearch":{
            "version":"6.3.0", 
            "allocated_memory":12000000, 
            "max_allocated_memory":16000000, 
            "cluster_name":"", 
            "index_number_of_replicas":0
          }
        }
      )
    end

    describe '#generate' do
      it 'should generate elasticsearch attributes' do
        elastic_attributes = ElasticsearchRoleAttributesGenerator.new(
          @elastic_component,
          @infrastructure.infrastructure_components
        )
        
        attrs = elastic_attributes.generate

        expect(attrs).to eq({
            "consul"=>{
              "hosts"=>["#{@consul_component.ipaddress}"],
              "config"=>{
                "consul.json"=>{"bind_addr"=>"#{@elastic_component.ipaddress}"}
              },
              "run_as_server"=>false
            },
            "datadog"=>{
              "elastic"=>{
                "instances"=>[
                  {
                    "url"=>"",
                    "tags"=>[],
                  }
                ]
              },
              "datadog_api_key"=>"",
              "datadog_hostname"=>""
            },
            "run_list"=>["role[elasticsearch]", 'recipe[elasticsearch_wrapper_cookbook::elasticsearch_set_replica]'],
            "elasticsearch"=>{
              "version"=>"6.3.0", 
              "allocated_memory"=>12000000, 
              "max_allocated_memory"=>16000000, 
              "cluster_name"=>@infrastructure.cluster_name, 
              "index_number_of_replicas"=>0
            }
          }
        )
      end
    end
  end
end
