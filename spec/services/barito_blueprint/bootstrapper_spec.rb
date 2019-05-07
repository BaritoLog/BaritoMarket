require 'rails_helper'

module BaritoBlueprint
  RSpec.describe Bootstrapper do
    before(:each) do
      @infrastructure = create(:infrastructure)
      @executor = ChefSoloBootstrapper.new('/opt/chef-repo')
      @bootstrapper = Bootstrapper.new(
        @infrastructure,
        @executor,
        private_keys_dir: Figaro.env.private_keys_dir,
        private_key_name: Figaro.env.private_key_name,
        username: Figaro.env.username,
      )
    end

    describe '#bootstrap_instances!' do
      before(:each) do
        2.times.each do
          create(:infrastructure_component, infrastructure: @infrastructure)
        end
        allow(@provisioner).
          to receive(:generate_bootstrap_attributes).
          and_return({})
      end

      it 'should return false even if only one bootstrapping failure' do
        allow(@bootstrapper).to receive(:bootstrap_instance!).and_return(false)
        expect(@bootstrapper.bootstrap_instances!).to eq false
      end

      it 'should update infrastructure provisioning_status to BOOTSTRAP_ERROR on failure' do
        allow(@bootstrapper).to receive(:bootstrap_instance!).and_return(false)
        @bootstrapper.bootstrap_instances!
        expect(@infrastructure.provisioning_status).to eq 'BOOTSTRAP_ERROR'
      end

      it 'should return true if all bootstrapping succeed' do
        allow(@bootstrapper).to receive(:bootstrap_instance!).and_return(true)
        expect(@bootstrapper.bootstrap_instances!).to eq true
      end

      it 'should update infrastructure statuses if all bootstrapping succeed' do
        allow(@bootstrapper).to receive(:bootstrap_instance!).and_return(true)
        @bootstrapper.bootstrap_instances!
        expect(@infrastructure.provisioning_status).to eq 'FINISHED'
        expect(@infrastructure.status).to eq 'ACTIVE'
      end
    end

    describe '#bootstrap_instance!' do
      before(:each) do
        @component = build(:infrastructure_component)
      end

      it 'should return true if executor returns success' do
        allow(@executor).
          to receive(:bootstrap!).
          and_return('success' => true)
        expect(@bootstrapper.bootstrap_instance!(@component)).to eq true
      end

      it 'should update component status if executor returns success' do
        allow(@executor).
          to receive(:bootstrap!).
          and_return('success' => true)
        @bootstrapper.bootstrap_instance!(@component)
        expect(@component.status).to eq 'FINISHED'
        expect(@infrastructure.status).to eq 'ACTIVE'
      end

      it 'should return false if executor returns errors' do
        allow(@executor).
          to receive(:bootstrap!).
          and_return('success' => false)
        expect(@bootstrapper.bootstrap_instance!(@component)).to eq false
      end

      it 'should update component status if executor returns errors' do
        allow(@executor).
          to receive(:bootstrap!).
          and_return('success' => false)
        @bootstrapper.bootstrap_instance!(@component)
        expect(@component.status).to eq 'BOOTSTRAP_ERROR'
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
        component = create(:infrastructure_component, component_type: 'consul')
        expect(
          @bootstrapper.generate_bootstrap_attributes(component, [component]),
        ).to eq('hello' => 'world')
      end
    end
  end
end
