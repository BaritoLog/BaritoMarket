require 'rails_helper'

module ChefHelper
  RSpec.describe BaritoFlowProducerRoleAttributesGenerator do
    before(:each) do
      @producer_manifest = {
                  "type" => "barito-flow-producer",
                  "count" => 1,
                  "definition" => {
                    "container_type" => "stateless",
                    "strategy" => "RollingUpdate",
                    "allow_failure" => "false",
                    "source" => {
                      "mode" => "pull",              # can be local or pull. default is pull.
                      "alias" => "lxd-ubuntu-minimal-barito-flow-producer-0.13.2-2",
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
                        "barito-flow" => {
                          "producer" => {
                            "version" => "v0.13.2",
                            "env_vars" => {
                              "BARITO_CONSUL_URL" => "",
                              "BARITO_KAFKA_BROKERS" => "kafka.service.consul:9092",
                              "BARITO_PRODUCER_GRPC" => ":8080",
                              "BARITO_PRODUCER_REST" => ":8085",
                              "BARITO_PRODUCER_ADDRESS" => ":8081",
                              "BARITO_PRODUCER_MAX_TPS" => 0,
                              "BARITO_CONSUL_KAFKA_NAME" => "kafka",
                              "BARITO_PRODUCER_REST_API" => "false",
                              "BARITO_KAFKA_TOPIC_SUFFIX" => "_pb",
                              "BARITO_KAFKA_PRODUCER_TOPIC" => "barito-log",
                              "BARITO_PRODUCER_RATE_LIMIT_RESET_INTERVAL" => 10
                            }
                          }
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
                    "name" => "haza-consul",
                    "cluster_name" => "barito",
                    "type" => "consul",
                    "count" => 1,
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
      @manifests = [@producer_manifest, @consul_manifest]
    end

    describe '#generate' do
      it 'should generate producer attributes' do
        producer_attributes = BaritoFlowProducerRoleAttributesGenerator.new(
          @producer_manifest,
          @manifests
        )

        attrs = producer_attributes.generate

        expect(attrs).to eq({
            "consul"=>{
              "hosts"=>"$pf-meta:deployment_ip_addresses?deployment_name=-consul",
              "run_as_server"=>false
            },
            "run_list"=>["role[barito-flow-producer]"],

            "barito-flow"=>{
              "producer"=>{
                "version"=>"v0.11.8", 
                "env_vars"=>{
                  "BARITO_CONSUL_URL"=>"http://consul.service.consul:8500", 
                  "BARITO_KAFKA_BROKERS"=>"kafka.service.consul:9092", 
                  "BARITO_PRODUCER_ADDRESS"=>":8080", 
                  "BARITO_PRODUCER_MAX_TPS"=>@producer_manifest['definition']['bootstrappers'][0]['bootstrap_attributes']['barito-flow']['producer']['env_vars']['BARITO_PRODUCER_MAX_TPS'], 
                  "BARITO_CONSUL_KAFKA_NAME"=>"kafka", 
                  "BARITO_KAFKA_PRODUCER_TOPIC"=>"barito-log", 
                  "BARITO_PRODUCER_RATE_LIMIT_RESET_INTERVAL"=>10
                }
              }
            }
          }
        )
      end
    end
  end
end
