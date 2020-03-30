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
  end
end
