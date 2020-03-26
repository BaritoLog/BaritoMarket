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
  end
end
