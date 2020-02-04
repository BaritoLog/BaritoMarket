require 'rails_helper'

module ChefHelper
  RSpec.describe ConsulRoleAttributesGenerator do
    before(:each) do
      @component = create(:infrastructure_component, 
        hostname:       'test-consul-01',
        component_type: 'consul',
        ipaddress:      nil
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
                "hosts"=> ["#{@component.hostname}.node.consul"]
            }, 
            "run_list"=> ["role[consul]"]
          }
        )
      end
    end
  end
end
