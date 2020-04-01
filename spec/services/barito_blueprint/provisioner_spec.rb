require 'rails_helper'

module BaritoBlueprint
  RSpec.describe BaritoBlueprint::Provisioner do
    before(:each) do
      @infrastructure = create(:infrastructure)
      @executor = PathfinderProvisioner.new('127.0.0.1:3000', 'abc', 'barito')
      @provisioner = Provisioner.new(
        @infrastructure,
        @executor,
        timeout: 0.second,
        check_interval: 0.second,
      )
    end

    describe '#batch!' do
      before(:each) do
      end

      it 'should return true if executor returns success' do
        allow(@executor).
          to receive(:batch!).
          and_return('success' => true)
        @provisioner.batch!
        expect(@provisioner.batch!).to eq true
      end

      it 'should update provisioning status when success' do
        allow(@executor).
          to receive(:batch!).
          and_return('success' => true)
        @provisioner.batch!
        expect(@infrastructure.provisioning_status).to eq 'DEPLOYMENT_FINISHED'
      end

      it 'should return false if executor returns errors' do
        allow(@executor).
          to receive(:batch!).
          and_return('success' => false)
        @provisioner.batch!
        expect(@provisioner.batch!).to eq false
      end

      it 'should update provisioning status when failed' do
        allow(@executor).
          to receive(:batch!).
          and_return('success' => false)
        @provisioner.batch!
        expect(@infrastructure.provisioning_status).to eq 'DEPLOYMENT_ERROR'
      end
    end

    describe '#delete!' do
      before(:each) do
      end

      it 'should return true if executor returns success' do
        allow(@provisioner).
          to receive(:update_manifests_by_params!).
          with({desired_num_replicas: 0, min_available_replicas: 0}).
          and_return('success' => true)

        allow(@executor).
          to receive(:batch!).
          and_return('success' => true)
        @provisioner.delete!
        expect(@provisioner.batch!).to eq true
      end

      it 'should update provisioning status when successs' do
        allow(@provisioner).
          to receive(:update_manifests_by_params!).
          with({desired_num_replicas: 0, min_available_replicas: 0}).
          and_return('success' => true)

        allow(@executor).
          to receive(:batch!).
          and_return('success' => true)
        @provisioner.delete!
        expect(@infrastructure.provisioning_status).to eq 'DELETED'
      end

      it 'should return false if executor returns errors' do
        allow(@provisioner).
          to receive(:update_manifests_by_params!).
          with({desired_num_replicas: 0, min_available_replicas: 0}).
          and_return('success' => true)

        allow(@executor).
          to receive(:batch!).
          and_return('success' => false)
        @provisioner.delete!
        expect(@provisioner.batch!).to eq false
      end

      it 'should update provisioning status when failed' do
        allow(@provisioner).
          to receive(:update_manifests_by_params!).
          with({desired_num_replicas: 0, min_available_replicas: 0}).
          and_return('success' => true)

        allow(@executor).
          to receive(:batch!).
          and_return('success' => false)
        @provisioner.delete!
        expect(@infrastructure.provisioning_status).to eq 'DELETE_ERROR'
      end
    end

    describe '#update_manifests_by_params!' do
      before(:each) do
        @infrastructure.manifests[0]['desired_num_replicas'] = 2
        @infrastructure.manifests[0]['min_available_replicas'] = 1
        @infrastructure.save
      end

      it 'should return proper value if executor returns success' do
        params = {desired_num_replicas: 0, min_available_replicas: 0}
        @provisioner.update_manifests_by_params!(params)

        expect(@infrastructure.manifests[0]['desired_num_replicas']).to eq 0
        expect(@infrastructure.manifests[0]['min_available_replicas']).to eq 0
      end

      it 'should return proper value if executor returns failed' do
        allow(@provisioner).
          to receive(:update_manifests_by_params!).
          and_return('success' => false)

        expect(@infrastructure.manifests[0]['desired_num_replicas']).to eq 2
        expect(@infrastructure.manifests[0]['min_available_replicas']).to eq 1
      end
    end

    describe '#reprovision_container!' do
      before(:each) do
        @container_hostname = 'container-consul-01'
        @container_source = {
          "mode": "pull",
          "alias": "lxd-ubuntu-minimal-consul-1.1.0-8",
          "remote": {
            "name": "barito-registry"
          }
        }
        @container_bootstrappers = [{
                                    "bootstrap_type": "chef-solo",
                                    "bootstrap_attributes": {
                                      "consul": {
                                        "hosts": []
                                      },
                                      "run_list": []
                                    },
                                    "bootstrap_cookbooks_url": "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
                                  }]
      end

      it 'should return true if executor returns success' do
        allow(@executor).
          to receive(:reprovision!).
          and_return('success' => true)
        expect(@provisioner.reprovision_container!(@container_hostname, @container_source, @container_bootstrappers)).to eq true
      end

      it 'should return false if executor returns errors' do
        allow(@executor).
          to receive(:reprovision!).
          and_return('success' => false)
        expect(@provisioner.reprovision_container!(@container_hostname, @container_source, @container_bootstrappers)).to eq false
      end
    end

    describe '#rebootstrap_container!' do
      before(:each) do
        @container_hostname = 'container-consul-01'
        @container_bootstrappers = [{
                                    "bootstrap_type": "chef-solo",
                                    "bootstrap_attributes": {
                                      "consul": {
                                        "hosts": []
                                      },
                                      "run_list": []
                                    },
                                    "bootstrap_cookbooks_url": "https://github.com/BaritoLog/chef-repo/archive/master.tar.gz"
                                  }]
      end

      it 'should return true if executor returns success' do
        allow(@executor).
          to receive(:rebootstrap!).
          and_return('success' => true)
        expect(@provisioner.rebootstrap_container!(@container_hostname, @container_bootstrappers)).to eq true
      end

      it 'should return false if executor returns errors' do
        allow(@executor).
          to receive(:rebootstrap!).
          and_return('success' => false)
        expect(@provisioner.rebootstrap_container!(@container_hostname, @container_bootstrappers)).to eq false
      end
    end

    describe '#schedule_delete_container!' do
      before(:each) do
        @container_hostname = 'container-consul-01'
      end

      it 'should return true if executor returns success' do
        allow(@executor).
          to receive(:delete_container!).
          and_return('success' => true)
        expect(@provisioner.schedule_delete_container!(@container_hostname)).to eq true
      end

      it 'should return false if executor returns errors' do
        allow(@executor).
          to receive(:delete_container!).
          and_return('success' => false)
        expect(@provisioner.schedule_delete_container!(@container_hostname)).to eq false
      end
    end

    ### LEGACY BLOCK
    ### WILL BE DELETED AFTER MIGRATION
    describe '#reprovision_instance!' do
      before(:each) do
        @component = build(:infrastructure_component)
      end

      it 'should return true if executor returns success' do
        allow(@executor).
          to receive(:reprovision!).
          and_return('success' => true)
        expect(@provisioner.reprovision_instance!(@component)).to eq true
      end

      it 'should return false if executor returns errors' do
        allow(@executor).
          to receive(:reprovision!).
          and_return('success' => false)
        expect(@provisioner.reprovision_instance!(@component)).to eq false
      end
    end
    ### END LEGACY BLOCK
  end
end
