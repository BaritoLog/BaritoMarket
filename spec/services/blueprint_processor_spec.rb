require 'rails_helper'

RSpec.describe BlueprintProcessor do
  before(:each) do
    @infrastructure = create(:infrastructure)
    @blueprint_hash = {
      'infrastructure_id' => @infrastructure.id,
      'cluster_name' => 'trac',
      'environment' => 'development',
      'nodes' => [
        {
          'name' => 'd-trac-consul-01',
          'type' => 'consul',
        },
        {
          'name' => 'd-trac-yggdrasil-01',
          'type' => 'yggdrasil',
        }
      ]
    }
  end

  describe '#process!' do
    context 'success' do
      before(:each) do
        # Mock sauron_provisioner
        sauron_provisioner = double
        allow(sauron_provisioner).to receive(:provision!).and_return({
          'success' => 'true',
          'error' => '',
          'data' => {
          }
        })
        allow(sauron_provisioner).to receive(:show_container).and_return({
          'success' => true,
          'data' => {
            'ipaddress' => 'xx.yy.zz.hh',
          }
        })
        allow(SauronProvisioner).to receive(:new).
          and_return(sauron_provisioner)

        # Mock chef_solo_bootstrapper
        chef_solo_bootstrapper = double
        allow(chef_solo_bootstrapper).to receive(:bootstrap!).and_return({
          'success' => true
        })
        allow(ChefSoloBootstrapper).to receive(:new).
          and_return(chef_solo_bootstrapper)
      end

      it 'should populate infrastructure_components based on return value from provisioner' do
        component_bootstrap_attributes = []
        bootstrap_attributes = [{
            'consul' => {
              'hosts' => ['xx.yy.zz.hh']
            },
            'run_list' => ['role[consul]']
          },
          {
            'run_list' => ['role[yggdrasil]']
          }
        ]
        blueprint_processor = BlueprintProcessor.new(@blueprint_hash)
        blueprint_processor.process!
        blueprint_processor.infrastructure_components.each do |component|
          expect(component.status).to eq "FINISHED"
          expect(component.ipaddress).to eq "xx.yy.zz.hh"
          component_bootstrap_attributes << component.bootstrap_attributes
          expect(bootstrap_attributes.include?(component.bootstrap_attributes)).to eq(true)
        end
        expect(bootstrap_attributes).to eq(component_bootstrap_attributes)
      end

      it 'should populate infrastructure components based on nodes' do
        hostnames = []
        blueprint_processor = BlueprintProcessor.new(@blueprint_hash)
        blueprint_processor.process!

        blueprint_processor.infrastructure_components.each do |component|
          hostnames << component.hostname
        end

        @blueprint_hash['nodes'].each do |node|
          expect(hostnames.include?(node['name'])).to eq(true)
        end
      end

      it 'should update consul host after provisioning is complete' do
        blueprint_processor = BlueprintProcessor.new(@blueprint_hash)
        blueprint_processor.process!
        @infrastructure.reload
        expect(@infrastructure.consul_host).to eq 'xx.yy.zz.hh:8500'
      end

      it 'should update infrastructure provisioning statuses after provisioning is complete' do
        blueprint_processor = BlueprintProcessor.new(@blueprint_hash)
        blueprint_processor.process!
        @infrastructure.reload
        expect(@infrastructure.provisioning_status).to eq 'FINISHED'
      end
    end

    context 'provisioning failure' do
      before(:each) do
        # Mock sauron_provisioner
        sauron_provisioner = double
        allow(sauron_provisioner).to receive(:provision!).and_return({
          'success' => false,
          'error' => '',
        })
        allow(SauronProvisioner).to receive(:new).
          and_return(sauron_provisioner)
      end

      it 'should update infrastructure provisioning statuses if provisioning fails' do
        blueprint_processor = BlueprintProcessor.new(@blueprint_hash)
        blueprint_processor.process!
        @infrastructure.reload
        expect(@infrastructure.provisioning_status).to eq 'PROVISIONING_ERROR'
      end
    end

    context 'bootstraping failure' do
      before(:each) do
        # Mock sauron_provisioner
        sauron_provisioner = double
        allow(sauron_provisioner).to receive(:provision!).and_return({
          'success' => 'true',
          'error' => '',
          'data' => {
          }
        })
        allow(sauron_provisioner).to receive(:show_container).and_return({
          'success' => true,
          'data' => {
            'ipaddress' => 'xx.yy.zz.hh',
          }
        })
        allow(SauronProvisioner).to receive(:new).
          and_return(sauron_provisioner)

        # Mock chef_solo_bootstrapper
        chef_solo_bootstrapper = double
        allow(chef_solo_bootstrapper).to receive(:bootstrap!).and_return({
          'success' => false,
          'error' => '',
        })
        allow(ChefSoloBootstrapper).to receive(:new).
          and_return(chef_solo_bootstrapper)
      end

      it 'should update first infrastructure component statuses if bootstraping fails' do
        blueprint_processor = BlueprintProcessor.new(@blueprint_hash)
        blueprint_processor.process!
        expect(blueprint_processor.infrastructure_components.first.status).to eq 'BOOTSTRAP_ERROR'
        @infrastructure.reload
        expect(@infrastructure.provisioning_status).to eq 'BOOTSTRAP_ERROR'
      end
    end

    context 'Retry bootstrap' do
      before(:each) do
        @retry_infrastructure = create(:infrastructure)
        failed_component = create(:infrastructure_component, infrastructure_id: @retry_infrastructure.id, status: 'BOOTSTRAP_ERROR')

        # Mock sauron_provisioner
        sauron_provisioner = double
        allow(sauron_provisioner).to receive(:provision!).and_return({
          'success' => 'true',
          'error' => '',
          'data' => {
          }
        })
        allow(sauron_provisioner).to receive(:show_container).and_return({
          'success' => true,
          'data' => {
            'ipaddress' => 'xx.yy.zz.hh',
          }
        })
        allow(SauronProvisioner).to receive(:new).
          and_return(sauron_provisioner)

        # Mock chef_solo_bootstrapper
        chef_solo_bootstrapper = double
        allow(chef_solo_bootstrapper).to receive(:bootstrap!).and_return({
         'success' => true
        })
        allow(ChefSoloBootstrapper).to receive(:new).
         and_return(chef_solo_bootstrapper)
      end

      it "should run retry bootstrap successfully" do
        expect(@retry_infrastructure.infrastructure_components.first.status).to eq 'BOOTSTRAP_ERROR'

        ordered_infrastructure_components = @retry_infrastructure.infrastructure_components.order(:sequence)

        blueprint_processor = BlueprintProcessor.new(nil, infrastructure_id: @retry_infrastructure.id)
        blueprint_processor.bootstrap_instances!(blueprint_processor.infrastructure.infrastructure_components)

        expect(@retry_infrastructure.infrastructure_components.first.status).to eq 'FINISHED'
      end
    end


    context "Check ipaddress" do
      before(:each) do
        @retry_infrastructure = create(:infrastructure, provisioning_status: 'PROVISIONING_STARTED')
        failed_component = create(:infrastructure_component, infrastructure_id: @retry_infrastructure.id, status: 'PROVISIONING_STARTED', ipaddress: nil)

        # Mock sauron_provisioner
        sauron_provisioner = double
        allow(sauron_provisioner).to receive(:provision!).and_return({
          'success' => 'true',
          'error' => '',
          'data' => {
          }
        })
        allow(sauron_provisioner).to receive(:show_container).and_return({
          'success' => true,
          'data' => {
            'ipaddress' => nil,
          }
        })
        allow(SauronProvisioner).to receive(:new).
          and_return(sauron_provisioner)

        # Mock chef_solo_bootstrapper
        chef_solo_bootstrapper = double
        allow(chef_solo_bootstrapper).to receive(:bootstrap!).and_return({
         'success' => true
        })
        allow(ChefSoloBootstrapper).to receive(:new).
         and_return(chef_solo_bootstrapper)
      end

      it "should update status if ipaddress doesn't returned by Sauron" do
        expect(@retry_infrastructure.infrastructure_components.first.status).to eq 'PROVISIONING_STARTED'
        expect(@retry_infrastructure.provisioning_status).to eq 'PROVISIONING_STARTED'

        ordered_infrastructure_components = @retry_infrastructure.infrastructure_components.order(:sequence)

        blueprint_processor = BlueprintProcessor.new(nil, infrastructure_id: @retry_infrastructure.id)
        blueprint_processor.check_ipaddress!(ordered_infrastructure_components.first)
        @retry_infrastructure.reload

        expect(@retry_infrastructure.infrastructure_components.first.status).to eq 'PROVISIONING_ERROR'
        expect(@retry_infrastructure.provisioning_status).to eq 'PROVISIONING_ERROR'
      end

      it "should update status if ipaddress doesn't returned by Sauron" do
        expect(@retry_infrastructure.infrastructure_components.first.ipaddress).to be_falsey

        # Mock sauron_provisioner
        sauron_provisioner = double
        allow(sauron_provisioner).to receive(:show_container).and_return({
          'success' => true,
          'data' => {
            'ipaddress' => 'aa.bb.cc.dd',
          }
        })
        allow(SauronProvisioner).to receive(:new).
          and_return(sauron_provisioner)

        ordered_infrastructure_components = @retry_infrastructure.infrastructure_components.order(:sequence)

        blueprint_processor = BlueprintProcessor.new(nil, infrastructure_id: @retry_infrastructure.id)
        blueprint_processor.check_ipaddress!(ordered_infrastructure_components.first)
        @retry_infrastructure.reload

        expect(@retry_infrastructure.infrastructure_components.first.status).to eq 'PROVISIONING_FINISHED'
        expect(@retry_infrastructure.infrastructure_components.first.ipaddress).to eq 'aa.bb.cc.dd'
        expect(@retry_infrastructure.provisioning_status).to eq 'PROVISIONING_FINISHED'
      end
    end
  end
end
