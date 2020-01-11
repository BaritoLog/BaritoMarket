require 'rails_helper'

module ChefHelper
  RSpec.describe ConsulRoleAttributesGenerator do
    before(:each) do
      @infrastructure = create(:infrastructure, cluster_name: 'test')
      @component = create(:infrastructure_component, 
        infrastructure: @infrastructure,
        hostname:       'test-consul-01',
        component_type: 'consul',
        ipaddress:      '127.0.0.1'
      )
      create(:infrastructure_component,
        infrastructure: @infrastructure,
        hostname:       'test-consul-02',
        component_type: 'consul',
        ipaddress:      '127.0.0.2'
      )
      create(:infrastructure_component,
        infrastructure: @infrastructure,
        hostname:       'test-consul-03',
        component_type: 'consul',
        ipaddress:      '127.0.0.3'
      )
    end

    describe '#generate' do
      it 'should generate consul attributes' do
        consul_attributes = ConsulRoleAttributesGenerator.new(
          @component,
          @infrastructure.infrastructure_components
        )
        
        attrs = consul_attributes.generate

        expect(attrs).to eq({
            "consul"=> 
              {
                "hosts"=> ["consul.service.consul"],
                "bootstrap_expect" => 2,
                "config"=> {
                  "consul.json"=> {"bind_addr"=> "#{@component.ipaddress}"}
              }
            }, 
            "run_list"=> ["role[consul]"]
          }
        )
      end
    end
  end
end
