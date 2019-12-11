require 'rails_helper'

RSpec.describe PathfinderProvisioner do
  describe '#provision!' do
    before(:all) do
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
      before(:all) do
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
      before(:all) do
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
    before(:all) do
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
    before(:all) do
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
end
