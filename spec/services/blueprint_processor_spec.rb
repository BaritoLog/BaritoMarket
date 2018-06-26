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

      it 'should populate nodes based on return value from provisioner' do
        blueprint_processor = BlueprintProcessor.new(@blueprint_hash)
        blueprint_processor.process!
        expect(blueprint_processor.nodes).to eq [
          {
            'name' => 'd-trac-consul-01',
            'type' => 'consul',
            'instance_attributes' => {
              'host_ipaddress' => 'xx.yy.zz.hh',
              'key_pair_name' => 'barito'
            },
            'bootstrap_attributes' => {
              'consul' => {
                'hosts' => ['xx.yy.zz.hh']
              },
              'run_list' => ['role[consul]']
            }
          },
          {
            'name' => 'd-trac-yggdrasil-01',
            'type' => 'yggdrasil',
            'instance_attributes' => {
              'host_ipaddress' => 'xx.yy.zz.hh',
              'key_pair_name' => 'barito'
            },
            'bootstrap_attributes' => {
              'run_list' => ['role[yggdrasil]']
            }
          }
        ]
      end

      it 'should update consul host after provisioning is complete' do
        blueprint_processor = BlueprintProcessor.new(@blueprint_hash)
        blueprint_processor.process!
        @infrastructure.reload
        expect(@infrastructure.consul_host).to eq 'xx.yy.zz.hh:8500'
      end
    end

    context 'failure' do
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

      it 'should populate nodes as failed if provisioning fails' do
        blueprint_processor = BlueprintProcessor.new(@blueprint_hash)
        blueprint_processor.process!
        expect(blueprint_processor.nodes).to eq [
          {
            'name' => 'd-trac-consul-01',
            'type' => 'consul',
          },
          {
            'name' => 'd-trac-yggdrasil-01',
            'type' => 'yggdrasil',
          }
        ]
      end
    end
  end
end
