require 'rails_helper'

module ChefHelper
  RSpec.describe ConsulRoleAttributesGenerator do
    before(:each) do
      @component = create(:infrastructure_component, 
        hostname: 'test-consul-01',
        category: 'consul',
        ipaddress: '127.0.0.1'
      )
      create(:component_template,
        name: 'consul', 
        component_attributes: {
          "consul": 
            {
              "hosts": [], 
              "config": {
                "consul.json": {"bind_addr": ""}
            }
          }, 
          "run_list": []
        }
      )
    end

    describe '#generate' do
      it 'should generate consul attributes' do
        consul_attributes = ConsulRoleAttributesGenerator.new(
          @component,
          [@component]
        )
        
        attrs = consul_attributes.generate

        expect(attrs).to eq({
            "consul"=> 
              {
                "hosts"=> ["#{@component.ipaddress}"], 
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
