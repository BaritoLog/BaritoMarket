require 'rails_helper'

module ChefHelper
  RSpec.describe ZookeeperRoleAttributesGenerator do
    before(:each) do
      @zookeeper_manifest = {
                    "name": "haza-zookeeper",
                    "cluster_name": "barito",
                    "type": "zookeeper",
                    "count": 1,
                    "definition": {
                      "container_type": "stateless",
                      "strategy": "RollingUpdate",
                      "allow_failure": "false",
                      "resource": {
                        "cpu_limit": "0-2",
                        "mem_limit": "5GB"
                      },
                      "source": {
                        "mode": "pull",
                        "alias": "lxd-ubuntu-minimal-zookeeper-3.4.12-3",
                        "remote": {
                          "name": "barito-registry"
                        },
                        "fingerprint": "",
                        "source_type": "image"                      
                      },
                      "bootstrappers": [{
                        "bootstrap_type": "chef-solo",
                        "bootstrap_attributes": {
                          "consul": {
                            "hosts": [

                            ],
                            "run_as_server": false
                          },
                          "run_list": [

                          ],
                          "zookeeper": {
                            "hosts": [
                              ""
                            ],
                            "my_id": ""
                          }
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
      @consul_manifest = {
                    "name": "haza-consul",
                    "cluster_name": "barito",
                    "type": "consul",
                    "count": 1,
                    "definition": {
                      "container_type": "stateless",
                      "strategy": "RollingUpdate",
                      "allow_failure": "false",
                      "source": {
                        "mode": "pull",
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
      @manifests = [@zookeeper_manifest, @consul_manifest]
      @my_id = 1
    end

    describe '#generate' do
      it 'should generate zookeeper attributes' do
        zookeeper_attributes = ZookeeperRoleAttributesGenerator.new(
          @zookeeper_manifest,
          @manifests
        )
        
        attrs = zookeeper_attributes.generate

        expect(attrs).to eq({
            "consul"=>{
              "hosts"=>"$pf-meta:deployment_ip_address?deployment_name=barito-consul", 
              "run_as_server"=>false
            },
            "datadog" => {
              "zk"=>{
                "instances"=>[{"host"=>"localhost", "port"=>2181, "tags"=>[], "cluster_name"=>""}]
              }, 
              "datadog_api_key"=>"", 
              "datadog_hostname"=>""
            },
            "run_list"=>["role[zookeeper]"], 
            "zookeeper"=>{
              "hosts"=>"$pf-meta:zookeeper_domains?key=value", 
              "my_id"=>"$pf-meta:zookeeper_myid?key=value"
            }
          }
        )
      end
    end
  end
end
