require 'rails_helper'

RSpec.describe PathfinderProvisioner do
  describe '#provision!' do
    before(:each) do
      @pathfinder_host = '127.0.0.1:3000'
      @pathfinder_token = 'abc'
      @pathfinder_cluster = 'barito'
      @source = {
        'source_type' => 'image',
        'mode' => 'pull',
        'remote' => {
            'name' => 'barito-registry'
          },
        'fingerprint' => '',
        'alias' => 'consul'
      }
      @bootstrappers = [{    
        "bootstrap_type" => "chef-solo",
        "bootstrap_cookbooks_url" => "",
        "bootstrap_attributes" => {
          "consul" => {
            "hosts" => [],
            "config" => {"consul.json" => {"bind_addr" => ""}}
          },
          "run_list" => []
        } 
      }]

      # Mock Pathfinder API
      stub_request(:post, "http://#{@pathfinder_host}/api/v2/ext_app/containers.json").
        with(
          query: {
            'cluster_name' => @pathfinder_cluster
          },
          body: {
            'container' => {
              'hostname' => 'test-01',
              'source' => @source,
              'bootstrappers' => @bootstrappers
            }
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'X-Auth-Token' => @pathfinder_token,
          }
        ).to_return({
          status: 201,
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
            'data' => {
              'ipaddress' => '127.0.0.1'
            }
          }.to_json
        })
    end

    it 'should make necessary calls to Pathfinder and return the response' do
      pathfinder_provisioner = PathfinderProvisioner.new(@pathfinder_host, @pathfinder_token, @pathfinder_cluster)
      provision_result = pathfinder_provisioner.provision!('test-01', @source, @bootstrappers)
      expect(provision_result).to eq({
        'success' => true,
        'data' => {'ipaddress' => '127.0.0.1'},
      })
    end
  end

  describe '#reprovision!' do
    context 'container already exist' do
      before(:each) do
        @pathfinder_host = '127.0.0.1:3000'
        @pathfinder_token = 'abc'
        @pathfinder_cluster = 'barito'
        @source = {
          'source_type' => 'image',
          'mode' => 'pull',
          'remote' => {
              'name' => 'barito-registry'
            },
          'fingerprint' => '',
          'alias' => 'consul'
        }
        @bootstrappers = [{    
          "bootstrap_type" => "chef-solo",
          "bootstrap_cookbooks_url" => "",
          "bootstrap_attributes" => {
            "consul" => {
              "hosts" => [],
              "config" => {"consul.json" => {"bind_addr" => ""}}
            },
            "run_list" => []
          } 
        }]

        # Mock Pathfinder API
        stub_request(:post, "http://#{@pathfinder_host}/api/v2/ext_app/containers/test-01/reschedule").
          with(
            query: {
              'cluster_name' => @pathfinder_cluster
            },
            headers: {
              'Content-Type' => 'application/json',
              'X-Auth-Token' => @pathfinder_token,
            }
          ).to_return({
            status: 201,
            headers: {
              'Content-Type' => 'application/json',
            },
            body: {
              'data' => {
                'ipaddress' => '127.0.0.1'
              }
            }.to_json
          })
      end

      it 'should make necessary calls to Pathfinder and return the response' do
        pathfinder_provisioner = PathfinderProvisioner.new(@pathfinder_host, @pathfinder_token, @pathfinder_cluster)
        provision_result = pathfinder_provisioner.reprovision!('test-01', @source, @bootstrappers)
        expect(provision_result).to eq({
          'success' => true,
          'data' => {'ipaddress' => '127.0.0.1'},
        })
      end
    end

    context 'container isn\'t exist already' do
      before(:each) do
        @pathfinder_host = '127.0.0.1:3000'
        @pathfinder_token = 'abc'
        @pathfinder_cluster = 'barito'
        @source = {
          'source_type' => 'image',
          'mode' => 'pull',
          'remote' => {
              'name' => 'barito-registry'
            },
          'fingerprint' => '',
          'alias' => 'consul'
        }
        @bootstrappers = [{    
          "bootstrap_type" => "chef-solo",
          "bootstrap_cookbooks_url" => "https://github.com/BaritoLog/kibana_wrapper_cookbook",
          "bootstrap_attributes" => {
            "consul" => {
              "hosts" => [],
              "config" => {"consul.json" => {"bind_addr" => ""}}
            },
            "run_list" => []
          } 
        }]
        
        # Mock Pathfinder API
        stub_request(:post, "http://#{@pathfinder_host}/api/v2/ext_app/containers/test-01/reschedule").
          with(
            query: {
              'cluster_name' => @pathfinder_cluster
            },
            headers: {
              'Content-Type' => 'application/json',
              'X-Auth-Token' => @pathfinder_token,
            }
          ).to_return({
            status: 404,
            headers: {
              'Content-Type' => 'application/json',
            },
            body: {
              'error' => { 'message' => 'Container not found' }
            }.to_json
          })

      stub_request(:post, "http://#{@pathfinder_host}/api/v2/ext_app/containers.json").
        with(
          query: {
            'cluster_name' => @pathfinder_cluster
          },
          body: {
            'container' => {
              'hostname' => 'test-01',
              'source' => @source,
              'bootstrappers' => @bootstrappers
            }
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'X-Auth-Token' => @pathfinder_token,
          }
        ).to_return({
          status: 201,
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
            'data' => {
              'ipaddress' => '127.0.0.1'
            }
          }.to_json
        })
      end

      it 'should make necessary calls to Pathfinder and return the response' do
        pathfinder_provisioner = PathfinderProvisioner.new(@pathfinder_host, @pathfinder_token, @pathfinder_cluster)
        provision_result = pathfinder_provisioner.reprovision!('test-01', @source, @bootstrappers)
        expect(provision_result).to eq({
          'success' => true,
          'data' => {'ipaddress' => '127.0.0.1'},
        })
      end
    end
  end

  describe '#delete_container!' do
    before(:each) do
      @pathfinder_host = '127.0.0.1:3000'
      @pathfinder_token = 'abc'
      @pathfinder_cluster = 'barito'

      # Mock Pathfinder API
      stub_request(:post, "http://#{@pathfinder_host}/api/v2/ext_app/containers/test-01/schedule_deletion").
        with(
          query: {
            'cluster_name' => @pathfinder_cluster
          },
          headers: {
            'Content-Type' => 'application/json',
            'X-Auth-Token' => @pathfinder_token,
          }
        ).to_return({
          status: 201,
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
            'data' => {
              'status' => 'SCHEDULE_DELETION'
            }
          }.to_json
        })
    end

    it 'should make necessary calls to Pathfinder and return the response' do
      pathfinder_provisioner = PathfinderProvisioner.new(@pathfinder_host, @pathfinder_token, @pathfinder_cluster)
      provision_result = pathfinder_provisioner.delete_container!('test-01')
      expect(provision_result).to eq({
        'success' => true,
        'data' => {
          'status' => 'SCHEDULE_DELETION'
        }
      })
    end
  end

  describe '#rebootstrap!' do
    before(:each) do
      @pathfinder_host = '127.0.0.1:3000'
      @pathfinder_token = 'abc'
      @pathfinder_cluster = 'barito'
      @bootstrappers = [{    
        "bootstrap_type" => "chef-solo",
        "bootstrap_cookbooks_url" => "https://github.com/BaritoLog/kibana_wrapper_cookbook",
        "bootstrap_attributes" => {
          "consul" => {
            "hosts" => [],
            "config" => {"consul.json" => {"bind_addr" => ""}}
          },
          "run_list" => []
        } 
      }]

      # Mock Pathfinder API
      stub_request(:post, "http://#{@pathfinder_host}/api/v2/ext_app/containers/test-01/rebootstrap").
        with(
          query: {
            'cluster_name' => @pathfinder_cluster,
          },
          body: {
            'bootstrappers' => @bootstrappers,
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'X-Auth-Token' => @pathfinder_token,
          }
        ).to_return({
          status: 200,
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
            'data' => {
              'status' => 'PROVISIONED'
            }
          }.to_json
        })
    end

    it 'should make necessary calls to Pathfinder and return the response' do
      pathfinder_provisioner = PathfinderProvisioner.new(@pathfinder_host, @pathfinder_token, @pathfinder_cluster)
      bootstrap_result = pathfinder_provisioner.rebootstrap!('test-01', @bootstrappers)
      expect(bootstrap_result).to eq({
        'success' => true,
        'data' => {'status' => 'PROVISIONED'}
      })
    end
  end

  describe "#bulk_apply!" do
    before(:each) do
      @pathfinder_host = '127.0.0.1:3000'
      @pathfinder_token = 'abc'
      @pathfinder_cluster = 'barito'
      @deployments = [{
        'name' => 'haza-consul',
        'cluster_name' => @pathfinder_cluster,
        'count' => 1,
        'definition' => "{
          'strategy': 'RollingUpdate',
          'allow_failure': 'false',
          'source': {
            'mode': 'pull',              # can be local or pull. default is pull.
            'alias': 'lxd-ubuntu-minimal-consul-1.1.0-8',
            'remote': {
              'name': 'barito-registry',
            },
            'fingerprint': '',
            'source_type': 'image',
          },
          'container_type': 'stateless',
          'resource': {
            'cpu_limit': '0-2',
            'mem_limit': '500MB',
          },
          'bootstrappers': [
            {
              'bootstrap_type': 'chef-solo',
              'bootstrap_attributes': {
                'consul': {
                  'hosts': [],
                },
                'run_list': [],
              },
              'bootstrap_cookbooks_url': 'https://github.com/BaritoLog/chef-repo/archive/master.tar.gz',
            }
          ],
          'healthcheck': {
            'type': 'tcp',
            'port': 9500,
            'endpoint': '',
            'payload': '',
            'timeout': '',
          }
        }"
      }]
      # Mock Pathfinder API
      stub_request(:post, "http://#{@pathfinder_host}/api/v2/ext_app/deployments/bulk_apply").
        with(
          body: {
            'deployments' => @deployments
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'X-Auth-Token' => @pathfinder_token,
          }
        ).to_return({
          status: 200,
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
          }.to_json
        })
    end
    it "should make necessary calls to Pathfinder and create new containers" do
      pathfinder_provisioner = PathfinderProvisioner.new(@pathfinder_host, @pathfinder_token, @pathfinder_cluster)
      bootstrap_result = pathfinder_provisioner.bulk_apply!(@deployments)
      expect(bootstrap_result).to eq({
        'success' => true
      })
    end
  end

  context "#GET list_containers!" do
    before(:each) do
      @pathfinder_host = '127.0.0.1:3000'
      @pathfinder_token = 'abc'
      @pathfinder_cluster = 'barito'
      # Mock Pathfinder API
      stub_request(:get, "http://#{@pathfinder_host}/api/v2/ext_app/deployments/list_containers").
        with(
          query: {
            'name' => 'haza-consul'
          },
          headers: {
            'Content-Type' => 'application/json',
            'X-Auth-Token' => @pathfinder_token,
          }
        ).to_return({
          status: 200,
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
            'data' => {
              'id' => 639,
              'name' => 'haza-consul',
              'count' => 1,
              'definition' => {
                'source' => {
                  'mode' => 'pull',
                  'alias' => 'lxd-ubuntu-minimal-consul-1.1.0-8',
                  'remote' => {
                    'name' => 'barito-registry'
                  },
                  'fingerprint' => '',
                  'source_type' => 'image'
                },
                'resource' => {
                  'cpu_limit' => '0-2',
                  'mem_limit' => '500MB'
                },
                'strategy' => 'RollingUpdate',
                'healthcheck' => {
                  'port' => 9500,
                  'type' => 'tcp',
                  'payload' => '',
                  'timeout' => '',
                  'endpoint' => ''
                },
                'allow_failure' => 'false',
                'bootstrappers' => [
                  {
                    'bootstrap_type' => 'chef-solo',
                    'bootstrap_attributes' => {
                      'consul' => {
                        'hosts' => []
                      },
                      'run_list' => []
                    },
                    'bootstrap_cookbooks_url' => 'https =>//github.com/BaritoLog/chef-repo/archive/master.tar.gz'
                  }
                ],
                'container_type' => 'stateless'
              },
              'containers' => [
                {
                  'id' => 1045,
                  'hostname' => 'haza-consul-01',
                  'ipaddress' => '10.0.0.1',
                  'source' => {
                    'id' => 180,
                    'source_type' => 'image',
                    'mode' => 'pull',
                    'remote' => {
                      'id' => 157,
                      'name' => 'remote-1',
                      'server' => 'https =>//cloud-images.ubuntu.com/releases',
                      'protocol' => 'lxd',
                      'auth_type' => 'tls'
                    },
                    'fingerprint' => 'fingerprint-1',
                    'alias' => 'alias-1'
                  },
                  'bootstrappers' => [
                    {
                      'bootstrap_type' => 'none'
                    }
                  ],
                  'node_hostname' => '',
                  'status' => 'PENDING',
                  'last_status_update_at' => '2020-03-03T07 =>41 =>50.191Z'
                }
              ]
            }
          }.to_json
        })
    end
    it "should make necessary calls to Pathfinder and get list containers" do
      pathfinder_provisioner = PathfinderProvisioner.new(@pathfinder_host, @pathfinder_token, @pathfinder_cluster)
      bootstrap_result = pathfinder_provisioner.list_containers!("haza-consul")
      expect(bootstrap_result).to eq({
        'success' => true,
        'data' => {
          'id' => 639,
          'name' => 'haza-consul',
          'count' => 1,
          'definition' => {
            'source' => {
              'mode' => 'pull',
              'alias' => 'lxd-ubuntu-minimal-consul-1.1.0-8',
              'remote' => {
                'name' => 'barito-registry'
              },
              'fingerprint' => '',
              'source_type' => 'image'
            },
            'resource' => {
              'cpu_limit' => '0-2',
              'mem_limit' => '500MB'
            },
            'strategy' => 'RollingUpdate',
            'healthcheck' => {
              'port' => 9500,
              'type' => 'tcp',
              'payload' => '',
              'timeout' => '',
              'endpoint' => ''
            },
            'allow_failure' => 'false',
            'bootstrappers' => [
              {
                'bootstrap_type' => 'chef-solo',
                'bootstrap_attributes' => {
                  'consul' => {
                    'hosts' => []
                  },
                  'run_list' => []
                },
                'bootstrap_cookbooks_url' => 'https =>//github.com/BaritoLog/chef-repo/archive/master.tar.gz'
              }
            ],
            'container_type' => 'stateless'
          },
          'containers' => [
            {
              'id' => 1045,
              'hostname' => 'haza-consul-01',
              'ipaddress' => '10.0.0.1',
              'source' => {
                'id' => 180,
                'source_type' => 'image',
                'mode' => 'pull',
                'remote' => {
                  'id' => 157,
                  'name' => 'remote-1',
                  'server' => 'https =>//cloud-images.ubuntu.com/releases',
                  'protocol' => 'lxd',
                  'auth_type' => 'tls'
                },
                'fingerprint' => 'fingerprint-1',
                'alias' => 'alias-1'
              },
              'bootstrappers' => [
                {
                  'bootstrap_type' => 'none'
                }
              ],
              'node_hostname' => '',
              'status' => 'PENDING',
              'last_status_update_at' => '2020-03-03T07 =>41 =>50.191Z'
            }
          ]
        }
      })
    end
  end

  describe '#update_container!' do
    before(:each) do
      @pathfinder_host = '127.0.0.1:3000'
      @pathfinder_token = 'abc'
      @pathfinder_cluster = 'barito'

      @component = create(:infrastructure_component)

      # Mock Pathfinder API
      stub_request(:post, "#{@pathfinder_host}/api/v2/ext_app/containers/#{@component.hostname}/update").
        with(
          query: {
            'cluster_name' => @pathfinder_cluster
          },
          body: {
            'hostname' => @component.hostname,
            'bootstrappers' => @component.bootstrappers,
            'source' => @component.source
          }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'X-Auth-Token' => @pathfinder_token,
          }
        ).to_return({
          status: 200,
          headers: {
            'Content-Type' => 'application/json',
          },
          body: {
            'data' => {
              'containers' => {
                'id' => 1045,
                'hostname' => @component.hostname,
                'ipaddress' => '10.0.0.1',
                'source' => @component.source,
                'bootstrappers' => @component.bootstrappers,
                'node_hostname' => '',
                'status' => 'PENDING',
                'last_status_update_at' => '2020-03-03T07 =>41 =>50.191Z'
              }
            }
          }.to_json
        })
    end

    it 'should make necessary calls to Pathfinder and return the response' do
      pathfinder_provisioner = PathfinderProvisioner.new(@pathfinder_host, @pathfinder_token, @pathfinder_cluster)
      provision_result = pathfinder_provisioner.update_container!(@component)
      expect(provision_result).to eq(true)
    end
  end
end
