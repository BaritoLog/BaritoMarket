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
          'success' => true,
          'data' => {
            'host_ipaddress' => 'xx.yy.zz.hh',
            'key_pair_name' => 'barito'
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
          component_bootstrap_attributes << component.bootstrap_attribute
          expect(bootstrap_attributes.include?(component.bootstrap_attribute)).to eq(true)
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
          'success' => true,
          'data' => {
            'host_ipaddress' => 'xx.yy.zz.hh',
            'key_pair_name' => 'barito'
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
        expect(blueprint_processor.infrastructure_components.last.status).to eq 'PROVISIONING_FINISHED'
        @infrastructure.reload
        expect(@infrastructure.provisioning_status).to eq 'BOOTSTRAP_ERROR'

      end
    end
  end
end
