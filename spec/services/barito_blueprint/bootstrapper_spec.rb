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

      it 'should return true if all bootstrapping succeed' do
        allow(@bootstrapper).to receive(:bootstrap_instance!).and_return(true)
        expect(@bootstrapper.bootstrap_instances!).to eq true
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
        expect(@bootstrapper.bootstrap_instance!(@component, {})).to eq true
      end

      it 'should return false if executor returns errors' do
        allow(@executor).
          to receive(:bootstrap!).
          and_return('success' => false)
        expect(@bootstrapper.bootstrap_instance!(@component, {})).to eq false
      end
    end

    describe '#generate_bootstrap_attributes' do
      it 'should return proper attributes based on the component category' do
        generator = double('generator')
        allow(generator).
          to receive(:generate).
          and_return({'hello' => 'world'})
        allow(ChefHelper::ConsulRoleAttributesGenerator).
          to receive(:new).
          and_return(generator)
        component = create(:infrastructure_component, category: 'consul')
        expect(
          @bootstrapper.generate_bootstrap_attributes(component, [component])
        ).to eq({'hello' => 'world'})
      end
    end
  end
end
