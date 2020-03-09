require 'rails_helper'

module ChefHelper
  RSpec.describe KibanaRoleAttributesGenerator do
    before(:each) do
      @kibana_manifest = {
                  "name": "haza-consul",
                  "cluster_name": "barito",
                  "type": "kibana",
                  "count": 1,
                  "definition": {
                    "container_type": "stateless",
                    "strategy": "RollingUpdate",
                    "allow_failure": "false",
                    "source": {
                      "mode": "pull",              # can be local or pull. default is pull.
                      "alias": "lxd-ubuntu-minimal-kibana-6.8.5-1",
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
                          "hosts": [],
                          "run_as_server": false
                        },
                        "kibana": {
                          "config": {
                            "message_format": "Warning: TPS exceeded on these apps: %s. Please ask app group owner to <a style='text-decoration: underline; color: yellow;' target='_blank' href='https://gopay-systems.pages.golabs.io/wiki/products/barito/user/troubleshooting.html#got-alert-tps-an-app-exceeded-on-kibana'>increase TPS</a>.",
                            "prometheus_url": "http://prometheus.barito.golabs.io:9090",
                            "server.basePath": "",
                            "elasticsearch.url": "http://elasticsearch.service.consul:9200"
                          },
                          "version": "6.8.5"
                        },
                        "run_list": [],
                        "kibana_exporter": {
                          "kibana_version": "6.8.5"
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
      @manifests = [@kibana_manifest, @consul_manifest]
    end

    describe '#generate' do
      it 'should generate kibana attributes' do
        consumer_attributes = KibanaRoleAttributesGenerator.new(
          @kibana_manifest,
          @manifests
        )
        attrs = consumer_attributes.generate

        expect(attrs).to eq({
            "consul"=>{
              "hosts"=>"$pf-meta:deployment_ip_addresses?deployment_name=barito-consul",
              "run_as_server"=>false
            },
            "kibana"=>{
              "config"=>{
                "server.basePath"=>"/barito",
                "elasticsearch.url"=>"http://elasticsearch.service.consul:9200"
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
