require 'rails_helper'

module ChefHelper
  RSpec.describe ConsulRoleAttributesGenerator do
    before(:each) do
      @manifest = {
                    "name": "haza-consul",
                    "cluster_name": "barito",
                    "type": "consul",
                    "count": 1,
                    "definition": {
                      "container_type": "stateless",
                      "strategy": "RollingUpdate",
                      "allow_failure": "false",
                      "source": {
                        "mode": "pull",              # can be local or pull. default is pull.
                        "alias": "lxd-ubuntu-minimal-consul-1.1.0-8",
                        "remote": {
                          "name": "barito-registry"
                        },
                        "fingerprint": "",
                        "source_type": "image"                      
                      },
                      "resource": {
                        "cpu_limit": "0-2",
                        "mem_limit": "500MB"
                      },
                      "bootstrappers": [{
                        "bootstrap_type": "chef-solo",
                        "bootstrap_attributes": {
                          "consul": {
                            "hosts": []
                          },
                          "run_list": []
                        },
                        "bootstrap_cookbooks_url": "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
                      }],
                      "healthcheck": {
                        "type": "tcp",
                        "port": 9500,
                        "endpoint": "",
                        "payload": "",
                        "timeout": ""
                      }
                    }
                  }
    end

    describe '#generate' do
      it 'should generate consul attributes' do
        consul_attributes = ConsulRoleAttributesGenerator.new(
          @manifest,
          [@manifest]
        )
        
        attrs = consul_attributes.generate

        expect(attrs).to eq({
            "consul"=> 
              {
                "hosts"=> "$pf-meta:deployment_ip_addresses?deployment_name=haza-consul"
            }, 
            "run_list"=> ["role[consul]"]
          }
        )
      end
    end
  end
end
