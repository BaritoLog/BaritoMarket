require 'rails_helper'

module BaritoBlueprint
  RSpec.describe BaritoBlueprint::Provisioner do
    before(:each) do
      @infrastructure = create(:infrastructure)
      @executor = PathfinderProvisioner.new('127.0.0.1:3000', 'abc', 'barito')
      @provisioner = Provisioner.new(
        @infrastructure,
        @infrastructure.infrastructure_components,
        @executor,
        timeout: 0.second,
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

      it 'should update infrastructure provisioning_status even if only one provisioning failure' do
        allow(@provisioner).to receive(:provision_instance!).and_return(false)
        @provisioner.provision_instances!
        expect(@infrastructure.provisioning_status).to eq 'PROVISIONING_ERROR'
      end

      it 'should return true if all provisioning succeed' do
        allow(@provisioner).to receive(:provision_instance!).and_return(true)
        expect(@provisioner.provision_instances!).to eq true
      end

      it 'should update infrastructure provisioning_status if all provisioning succeed' do
        allow(@provisioner).to receive(:provision_instance!).and_return(true)
        @provisioner.provision_instances!
        expect(@infrastructure.provisioning_status).to eq 'PROVISIONING_FINISHED'
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

    describe '#check_and_update_instances' do
      before(:each) do
        2.times.each do
          create(:infrastructure_component,
            infrastructure: @infrastructure,
            ipaddress: '1.2.3.4')
        end
      end

      context 'positive scenario' do
        before(:each) do
          allow(@provisioner).
            to receive(:check_and_update_instance).
            and_return(true)
          allow(@provisioner).
            to receive(:valid_instances?).
            and_return(true)
        end

        it 'should return true if all components are valid' do
          expect(@provisioner.check_and_update_instances).to eq true
        end

        it 'should update infrastructure provisioning_status if all components are valid' do
          @provisioner.check_and_update_instances
          expect(@infrastructure.provisioning_status).to eq 'FINISHED'
        end
      end

      context 'negative scenario' do
        before (:each) do
          allow(@provisioner).
            to receive(:check_and_update_instance).
            and_return(false)
          allow(@provisioner).
            to receive(:valid_instances?).
            and_return(false)
        end

        it 'should return false even if only one invalid component' do
          expect(@provisioner.check_and_update_instances).to eq false
        end

        it 'should update infrastructure provisioning_status even if only one invalid component' do
          @provisioner.check_and_update_instances
          expect(@infrastructure.provisioning_status).to eq 'PROVISIONING_CHECK_FAILED'
        end
      end
    end

    describe '#check_and_update_instance' do
      before(:each) do
        @component = build(:infrastructure_component)
        allow(@executor).to receive(:show_container).and_return(
          'data' => { 'ipaddress' => '10.20.30.40' },
        )
      end

      it 'should return true if show_container returns ip address properly' do
        expect(@provisioner.check_and_update_instance(@component)).to eq true
      end

      it 'should update consul_host in infrastructure' do
        @component.update!(component_type: 'consul')
        infrastructure = @component.infrastructure
        expect(@provisioner.check_and_update_instance(@component)).to eq true
        infrastructure.reload
        consul_host = @component.ipaddress || @component.hostname

        expect(@component.ipaddress).to eq '10.20.30.40'
        expect(infrastructure.consul_host).to eq "#{consul_host}:#{Figaro.env.default_consul_port}"
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

    describe '#delete_instances!' do
      before(:each) do
        2.times.each do
          create(:infrastructure_component, infrastructure: @infrastructure)
        end
      end

      it 'should return false even if only one deleting failure' do
        allow(@provisioner).to receive(:delete_instance!).and_return(false)
        expect(@provisioner.delete_instances!).to eq false
      end

      it 'should update infrastructure provisioning_status even if only one provisioning failure' do
        allow(@provisioner).to receive(:delete_instance!).and_return(false)
        @provisioner.delete_instances!
        expect(@infrastructure.provisioning_status).to eq 'DELETE_ERROR'
      end

      it 'should return true if all deleting succeed' do
        allow(@provisioner).to receive(:delete_instance!).and_return(true)
        expect(@provisioner.delete_instances!).to eq true
      end

      it 'should update infrastructure provisioning_status if all deleting succeed' do
        allow(@provisioner).to receive(:delete_instance!).and_return(true)
        @provisioner.delete_instances!
        expect(@infrastructure.provisioning_status).to eq 'DELETED'
      end
    end

    describe '#delete_instance!' do
      before(:each) do
        @component = build(:infrastructure_component)
      end

      it 'should return true if executor returns success' do
        allow(@executor).
          to receive(:delete_container!).
          and_return('success' => true)
        expect(@provisioner.delete_instance!(@component)).to eq true
      end

      it 'should return false if executor returns errors' do
        allow(@executor).
          to receive(:delete_container!).
          and_return('success' => false)
        expect(@provisioner.delete_instance!(@component)).to eq false
      end
    end
  end
end
