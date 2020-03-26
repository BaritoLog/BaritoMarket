require 'rails_helper'

module ChefHelper
  RSpec.describe BaritoFlowConsumerRoleAttributesGenerator do
    before(:each) do
      @consumer_manifest = {
                  "type" => "barito-flow-consumer",
                  "desired_num_replicas" => 1,
                  "min_available_replicas" => 0,
                  "deployment_cluster_name"=>"guja",
                  "definition" => {
                    "container_type" => "stateless",
                    "strategy" => "RollingUpdate",
                    "allow_failure" => "false",
                    "source" => {
                      "mode" => "pull",              # can be local or pull. default is pull.
                      "alias" => "lxd-ubuntu-minimal-barito-flow-consumer-0.13.2-2",
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
                          "hosts" => [

                          ],
                          "config" => {
                            "consul.json" => {
                              "bind_addr" => ""
                            }
                          },
                          "run_as_server" => false
                        },
                        "run_list" => [

                        ],
                        "barito-flow" => {
                          "consumer" => {
                            "version" => "v0.13.2",
                            "env_vars" => {
                              "BARITO_CONSUL_URL" => "http://consul.service.consul:8500",
                              "BARITO_KAFKA_BROKERS" => "kafka.service.consul:9092",
                              "BARITO_KAFKA_GROUP_ID" => "barito-group",
                              "BARITO_PUSH_METRIC_URL" => "",
                              "BARITO_CONSUL_KAFKA_NAME" => "kafka",
                              "BARITO_ELASTICSEARCH_URL" => "http://elasticsearch.service.consul:9200",
                              "BARITO_KAFKA_TOPIC_SUFFIX" => "_pb",
                              "BARITO_KAFKA_CONSUMER_TOPICS" => "barito-log",
                              "BARITO_CONSUL_ELASTICSEARCH_NAME" => "elasticsearch"
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
      @manifests = [@consumer_manifest, @consul_manifest]
    end

    describe '#generate' do
      it 'should generate consumer attributes' do
        consumer_attributes = BaritoFlowConsumerRoleAttributesGenerator.new(
          @consumer_manifest,
          @manifests
        )

        attrs = consumer_attributes.generate

        expect(attrs).to eq({
            "consul"=>{
              "hosts"=>"$pf-meta:deployment_ip_addresses?deployment_name=guja-consul",
              "run_as_server"=>false
            },
            "run_list"=>["role[barito-flow-consumer]"],
            "barito-flow" => {
              "consumer"=>{
                "version"=>"v0.11.8", 
                "env_vars"=>{
                  "BARITO_CONSUL_URL"=>"http://consul.service.consul:8500", 
                  "BARITO_KAFKA_BROKERS"=>"kafka.service.consul:9092", 
                  "BARITO_KAFKA_GROUP_ID"=>"barito-group", 
                  "BARITO_PUSH_METRIC_URL"=>"http://market.barito.local//api/increase_log_count", 
                  "BARITO_CONSUL_KAFKA_NAME"=>"kafka", 
                  "BARITO_ELASTICSEARCH_URLS"=>"http://elasticsearch.service.consul:9200", 
                  "BARITO_KAFKA_CONSUMER_TOPICS"=>"barito-log", 
                  "BARITO_CONSUL_ELASTICSEARCH_NAME"=>"elasticsearch"
                }
              }
            }
          }
        )
      end
    end
  end
end
