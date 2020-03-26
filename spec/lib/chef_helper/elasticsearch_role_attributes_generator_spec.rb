require 'rails_helper'

module ChefHelper
  RSpec.describe ElasticsearchRoleAttributesGenerator do
    before(:each) do
      @elastic_manifest = {
                  "name" => "haza-consul",
                  "cluster_name" => "barito",
                  "deployment_cluster_name"=>"guja",
                  "type" => "elasticsearch",
                  "desired_num_replicas" => 1,
                  "min_available_replicas" => 0,
                  "definition" => {
                    "container_type" => "stateful",
                    "strategy" => "RollingUpdate",
                    "allow_failure" => "false",
                    "source" => {
                      "mode" => "pull",              # can be local or pull. default is pull.
                      "alias" => "lxd-ubuntu-minimal-elasticsearch-6.8.5-1",
                      "remote" => {
                        "name" => "barito-registry"
                      },
                      "fingerprint" => "",
                      "source_type" => "image"                      
                    },
                    "resource" => {
                      "cpu_limit" => "1-4",
                      "mem_limit" => "20GB"
                    },
                    "bootstrappers" => [{
                      "bootstrap_type" => "chef-solo",
                      "bootstrap_attributes" => {
                        "consul" => {
                          "hosts" => [],
                          "run_as_server" => false
                        },
                        "run_list" => [],
                        "elasticsearch" => {
                          "version" => "6.8.5",
                          "memory_lock" => false,
                          "node_master" => true,
                          "cluster_name" => "",
                          "allocated_memory" => 12000000,
                          "max_allocated_memory" => 16000000,
                          "minimum_master_nodes" => 1,
                          "index_number_of_replicas" => 1
                        }
                      },
                      "bootstrap_cookbooks_url" => "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
                    }],
                    "healthcheck" => {
                      "type" => "tcp",
                      "port" => 9500,
                      "endpoint" => "",
                      "payload" => "",
                      "timeout" => ""
                    }
                  }
                }
      @consul_manifest = {
                    "name" => "guja-consul",
                    "cluster_name" => "barito",
                    "deployment_cluster_name"=>"guja",
                    "type" => "consul",
                    "desired_num_replicas" => 1,
                    "min_available_replicas" => 0,
                    "definition" => {
                      "container_type" => "stateless",
                      "strategy" => "RollingUpdate",
                      "allow_failure" => "false",
                      "source" => {
                        "mode" => "pull",
                        "alias" => "lxd-ubuntu-minimal-consul-1.1.0-8",
                        "remote" => {
                          "name" => "barito-registry"
                        },
                        "fingerprint" => "",
                        "source_type" => "image"                      
                      },
                      "resource" => {
                        "cpu_limit" => "0-2",
                        "mem_limit" => "500MB"
                      },
                      "bootstrappers" => [{
                        "bootstrap_type" => "chef-solo",
                        "bootstrap_attributes" => {
                          "consul" => {
                            "hosts" => []
                          },
                          "run_list" => []
                        },
                        "bootstrap_cookbooks_url" => "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
                      }],
                      "healthcheck" => {
                        "type" => "tcp",
                        "port" => 9500,
                        "endpoint" => "",
                        "payload" => "",
                        "timeout" => ""
                      }
                    }
                  }
      @manifests = [@elastic_manifest, @consul_manifest]
    end

    describe '#generate' do
      it 'should generate elasticsearch attributes' do
        elastic_attributes = ElasticsearchRoleAttributesGenerator.new(
          @elastic_manifest,
          @manifests
        )
        
        attrs = elastic_attributes.generate

        expect(attrs).to eq({
            "consul"=>{
              "hosts"=>"$pf-meta:deployment_ip_addresses?deployment_name=guja-consul",
              "run_as_server"=>false
            },
            "datadog" => {
              "elastic"=>{
                "instances"=>[{
                  "url"=>"",
                  "tags"=>[]
                }]
              }, 
              "datadog_api_key"=>"", 
              "datadog_hostname"=>""
            },
            "run_list"=>["role[elasticsearch]", 'recipe[elasticsearch_wrapper_cookbook::elasticsearch_set_replica]'],
            "elasticsearch"=>{
              "version"=>"6.3.0", 
              "cluster_name"=>"guja",
              "allocated_memory"=>12000000, 
              "max_allocated_memory"=>16000000, 
              "minimum_master_nodes"=>1, 
              "index_number_of_replicas"=>0, 
              "member_hosts"=>["elasticsearch.service.consul"]
            }
          }
        )
      end
    end
  end
end
