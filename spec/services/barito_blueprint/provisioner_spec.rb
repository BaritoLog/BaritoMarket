require 'rails_helper'

module BaritoBlueprint
  RSpec.describe BaritoBlueprint::Provisioner do
    before(:each) do
      @infrastructure = create(:infrastructure)
      @executor = PathfinderProvisioner.new('127.0.0.1:3000', 'abc', 'barito')
      @provisioner = Provisioner.new(
        @infrastructure, 
        @executor,
        timeout: 1.second,
        check_interval: 0.second,
      )
    end

    describe '#provision_instances!' do
      before(:each) do
        2.times.each do
          create(:infrastructure_component, infrastructure: @infrastructure)
        end
      end

      it 'should return false even if only one provisioning failure' do
        allow(@provisioner).to receive(:provision_instance!).and_return(false)
        expect(@provisioner.provision_instances!).to eq false
      end

      it 'should return true if all provisioning succeed' do
        allow(@provisioner).to receive(:provision_instance!).and_return(true)
        expect(@provisioner.provision_instances!).to eq true
      end
    end

    describe '#provision_instance!' do
      before(:each) do
        @component = build(:infrastructure_component)
      end

      it 'should return true if executor returns success' do
        allow(@executor).
          to receive(:provision!).
          and_return('success' => true)
        expect(@provisioner.provision_instance!(@component)).to eq true
      end

      it 'should return false if executor returns errors' do
        allow(@executor).
          to receive(:provision!).
          and_return('success' => false)
        expect(@provisioner.provision_instance!(@component)).to eq false
      end
    end

    describe '#check_and_update_instances' do
      before(:each) do
        2.times.each do
          create(:infrastructure_component, 
            infrastructure: @infrastructure, 
            ipaddress: '1.2.3.4',
          )
        end
      end

      it 'should return false even if only one invalid component' do
        allow(@provisioner).to receive(:check_instance).and_return([
          false, 
          { error: "" }
        ])
        component = create(:infrastructure_component, 
          infrastructure: @infrastructure,
        )
        expect(@provisioner.check_and_update_instances).to eq false
      end

      it 'should return true if all components are valid' do
        allow(@provisioner).to receive(:check_instance).and_return([
          true, 
          { ipaddress: "1.2.3.4" }
        ])
        expect(@provisioner.check_and_update_instances).to eq true
      end

      it 'should make sure that every component has ip address' do
        allow(@provisioner).to receive(:check_instance).and_return([
          true, 
          { ipaddress: "1.2.3.4" }
        ])
        component = create(:infrastructure_component, 
          infrastructure: @infrastructure,
        )
        @provisioner.check_and_update_instances
        component.reload
        expect(component.ipaddress).to_not eq nil
      end
    end

    describe '#check_instance' do
      before(:each) do
        @component = build(:infrastructure_component)
      end

      it 'should return true if show_container returns ip address properly' do
        allow(@executor).to receive(:show_container).and_return(
          { 'data' => { 'ipaddress' => '1.2.3.4' }}
        )
        expect(@provisioner.check_instance(@component)).to eq [
          true, 
          { ipaddress: "1.2.3.4" }
        ]
      end

      it 'should return false if show_container doesn\'t return ip address' do
        allow(@executor).to receive(:show_container).and_return({})
        expect(@provisioner.check_instance(@component)).to eq [
          false, 
          { error: "" }
        ]
      end
    end

    describe '#valid_instances?' do
      before(:each) do
        @component = build(:infrastructure_component)
      end

      it 'should return false even if only one invalid component' do
        allow(@provisioner).to receive(:valid_instance?).and_return(false)
        expect(@provisioner.valid_instances?([@component])).to eq false
      end

      it 'should return true if all supplied components are valid' do
        allow(@provisioner).to receive(:valid_instance?).and_return(true)
        expect(@provisioner.valid_instances?([@component])).to eq true
      end
    end

    describe '#valid_instance?' do
      it 'should return false if component instance doesn\'t have ip address' do
        component = build(:infrastructure_component, ipaddress: nil)
        expect(@provisioner.valid_instance?(component)).to eq false
      end

      it 'should return true if a component instance has all the attributes' do
        component = build(:infrastructure_component, ipaddress: '1.2.3.4')
        expect(@provisioner.valid_instance?(component)).to eq true
      end
    end
  end
end