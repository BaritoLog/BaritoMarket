require 'rails_helper'

module ChefHelper
  RSpec.describe KafkaRoleAttributesGenerator do
    before(:each) do
      @kafka_manifest = {
                  "type" => "kafka",
                  "count" =>1,
                  "min_available_count" => 0,
                  "deployment_cluster_name"=>"guja",
                  "definition" =>{
                    "container_type" => "stateful",
                    "strategy" => "RollingUpdate",
                    "allow_failure" => "false",
                    "source" =>{
                      "mode" => "pull",              # can be local or pull. default is pull.
                      "alias" => "lxd-ubuntu-minimal-kafka-2.11-8",
                      "remote" =>{
                        "name" => "barito-registry"
                      },
                      "fingerprint" => "",
                      "source_type" => "image"                      
                    },
                    "resource" =>{
                      "cpu_limit" => "1-4",
                      "mem_limit" => "10GB"
                    },
                    "bootstrappers" =>[{
                      "bootstrap_type" => "chef-solo",
                      "bootstrap_attributes" =>{
                        "kafka" =>{
                          "kafka" =>{
                            "hosts" =>[],
                            "hosts_count" =>1
                          },
                          "zookeeper" =>{
                            "hosts" =>[]
                          },
                          "scala_version" => "2.11",
                          "confluent_version" => "5.3.0"
                        },
                        "consul" =>{
                          "hosts" =>[],
                          "run_as_server" =>false
                        },
                        "run_list" =>[]
                      },
                      "bootstrap_cookbooks_url" => "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
                    }],
                    "healthcheck" =>{
                      "type" => "tcp",
                      "port" =>9500,
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
              "count" =>1,
              "min_available_count" => 0,
              "definition" =>{
                "container_type" => "stateless",
                "strategy" => "RollingUpdate",
                "allow_failure" => "false",
                "source" =>{
                  "mode" => "pull",
                  "alias" => "lxd-ubuntu-minimal-consul-1.1.0-8",
                  "remote" =>{
                    "name" => "barito-registry"
                  },
                  "fingerprint" => "",
                  "source_type" => "image"                      
                },
                "resource" =>{
                  "cpu_limit" => "0-2",
                  "mem_limit" => "500MB"
                },
                "bootstrappers" =>[{
                  "bootstrap_type" => "chef-solo",
                  "bootstrap_attributes" =>{
                    "consul" =>{
                      "hosts" =>[]
                    },
                    "run_list" =>[]
                  },
                  "bootstrap_cookbooks_url" => "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
                }],
                "healthcheck" =>{
                  "type" => "tcp",
                  "port" => 9500,
                  "endpoint" => "",
                  "payload" => "",
                  "timeout" => ""
                }
              }
            }
      @manifests = [@kafka_manifest, @consul_manifest]
    end

    describe '#generate' do
      it 'should generate kafka attributes' do
        kafka_attributes = KafkaRoleAttributesGenerator.new(
          @kafka_manifest,
          @manifests
        )
        
        attrs = kafka_attributes.generate

        expect(attrs).to eq({
            "kafka"=>{
              "kafka"=>{
                "hosts"=>["kafka.service.consul"],
                "hosts_count"=>1
              }, 
              "zookeeper"=>{"hosts"=>["zookeeper.service.consul"]}
            },
            "datadog" => {
              "kafka"=>{
                "instances"=>[{"host"=>"localhost", "port"=>8090, "tags"=>[], "cluster_name"=>""}]
              }, 
              "datadog_api_key"=>"", 
              "datadog_hostname"=>""
            },
            "consul"=>{
              "hosts"=>"$pf-meta:deployment_ip_addresses?deployment_name=guja-consul",
              "run_as_server"=>false
            },
            "run_list"=>["role[kafka]"]
          }
        )
      end
    end
  end
end
