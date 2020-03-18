require 'rails_helper'

module BaritoBlueprint
  RSpec.describe Bootstrapper do
    before(:each) do
      @infrastructure = create(:infrastructure)
      @bootstrapper = Bootstrapper.new(
        @infrastructure,
        pathfinder_cluster: Figaro.env.pathfinder_cluster
      )
    end

    describe '#generate_manifests!' do
      before(:each) do
        allow(@provisioner).
          to receive(:generate_bootstrap_attributes).
          and_return({})
      end

      it 'should return false even if only one bootstrapping failure' do
        allow(@bootstrapper).to receive(:generate_manifest!).and_return([nil,false])
        expect(@bootstrapper.generate_manifests!).to eq false
      end

      it 'should update infrastructure provisioning_status to BOOTSTRAP_ERROR on failure' do
        allow(@bootstrapper).to receive(:generate_manifest!).and_return([nil,false])
        @bootstrapper.generate_manifests!
        expect(@infrastructure.provisioning_status).to eq 'BOOTSTRAP_ERROR'
      end

      it 'should return true if all bootstrapping succeed' do
        allow(@bootstrapper).to receive(:generate_manifest!).and_return(['',true])
        expect(@bootstrapper.generate_manifests!).to eq true
      end

      it 'should update infrastructure statuses if all bootstrapping succeed' do
        allow(@bootstrapper).to receive(:generate_manifest!).and_return(['',true])
        @bootstrapper.generate_manifests!
        expect(@infrastructure.provisioning_status).to eq 'BOOTSTRAP_FINISHED'
        expect(@infrastructure.status).to eq 'INACTIVE'
      end
    end

    describe '#generate_manifest!' do
      it 'should return true if executor returns success' do
        expected_manifest = {
                              "type"=>"consul",
                              "desired_num_replicas"=>1,
                              "min_available_replicas"=>0,
                              "deployment_cluster_name"=>"guja",
                              "definition"=>
                              {
                                "container_type"=>"stateless",
                                "strategy"=>"RollingUpdate",
                                "allow_failure"=>"false",
                                "source"=>
                                {
                                  "mode"=>"pull",
                                  "alias"=>"lxd-ubuntu-minimal-consul-1.1.0-8",
                                  "remote"=>{"name"=>"barito-registry"},
                                  "fingerprint"=>"",
                                  "source_type"=>"image"
                                },
                                "resource"=>{"cpu_limit"=>"0-2", "mem_limit"=>"500MB"},
                                "bootstrappers"=>
                                [
                                  {
                                    "bootstrap_type"=>"chef-solo",
                                    "bootstrap_attributes"=>{
                                      "consul"=>{
                                        "hosts"=>"$pf-meta:deployment_ip_addresses?deployment_name=guja-consul"
                                      }, 
                                      "run_list"=>["role[consul]"]
                                    },
                                    "bootstrap_cookbooks_url"=>"https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
                                  }
                                ],
                                "healthcheck"=>{"type"=>"tcp", "port"=>9500, "endpoint"=>"", "payload"=>"", "timeout"=>""}},
                              "name"=>"guja-consul",
                              "cluster_name"=>"default"
                            }
        expect(@bootstrapper.generate_manifest!(@infrastructure.manifests[0])).to eq [expected_manifest,true]
      end

      it 'should return nil and false if generate manifest failed' do
        generator = double('generator')
        allow(generator).
          to receive(:generate).
          and_return(nil, false)
        invalid_manifest = @infrastructure.manifests[0]
        invalid_manifest['definition']['bootstrappers'][0]['bootstrap_type'] = 'none'
        @bootstrapper.generate_manifest!(invalid_manifest)
        expect(@infrastructure.status).to eq 'INACTIVE'
      end
    end

    describe '#generate_bootstrap_attributes' do
      it 'should return proper attributes based on the component type' do
        generator = double('generator')
        allow(generator).
          to receive(:generate).
          and_return('hello' => 'world')
        allow(ChefHelper::ConsulRoleAttributesGenerator).
          to receive(:new).
          and_return(generator)
        manifest = {"type" => "consul"}
        expect(
          @bootstrapper.generate_bootstrap_attributes(manifest, [manifest]),
        ).to eq('hello' => 'world')
      end
    end
  end
end
