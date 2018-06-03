require 'rails_helper'

RSpec.describe BlueprintProcessor do
  before(:each) do
    @app = create(:barito_app)
    @blueprint_hash = {
      'application_id' => @app.id,
      'cluster_name' => 'trac',
      'environment' => 'development',
      'application_tps' => 'medium',
      'nodes' => [
        {
          'name' => 'd-trac-consul-01',
          'type' => 'consul',
          'node_container_config' => 'medium'
        },
        {
          'name' => 'd-trac-yggdrasil-01',
          'type' => 'yggdrasil',
          'node_container_config' => 'medium'
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
            'host' => 'xx.yy.zz.hh',
            'key_pair_name' => 'barito'
          }       
        })
        allow(SauronProvisioner).to receive(:new).and_return(sauron_provisioner)

        # Mock chef_solo_provisioner
        chef_solo_provisioner = double
        allow(chef_solo_provisioner).to receive(:provision!).and_return({
          'success' => true
        })
        allow(ChefSoloProvisioner).to receive(:new).and_return(chef_solo_provisioner)
      end

      it 'should populate nodes based on return value from provisioner' do
        blueprint_processor = BlueprintProcessor.new(@blueprint_hash)
        blueprint_processor.process!
        expect(blueprint_processor.nodes).to eq [
          {
            'name' => 'd-trac-consul-01',
            'type' => 'consul',
            'node_container_config' => 'medium',
            'provision_status' => 'APPS_PROVISIONED',
            'instance_attributes' => {
              'host' => 'xx.yy.zz.hh',
              'key_pair_name' => 'barito'
            },
            'apps_attributes' => {
              'consul' => {
                'hosts' => ['xx.yy.zz.hh']
              },
              'run_list' => ['role[consul]']
            }
          },
          {
            'name' => 'd-trac-yggdrasil-01',
            'type' => 'yggdrasil',
            'node_container_config' => 'medium',
            'provision_status' => 'APPS_PROVISIONED',
            'instance_attributes' => {
              'host' => 'xx.yy.zz.hh',
              'key_pair_name' => 'barito'
            },
            'apps_attributes' => {
              'run_list' => ['role[yggdrasil]']
            }
          }
        ]
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
        allow(SauronProvisioner).to receive(:new).and_return(sauron_provisioner)
      end

      it 'should populate nodes as failed if provisioning fails' do
        blueprint_processor = BlueprintProcessor.new(@blueprint_hash)
        blueprint_processor.process!
        expect(blueprint_processor.nodes).to eq [
          {
            'name' => 'd-trac-consul-01',
            'type' => 'consul',
            'node_container_config' => 'medium',
            'provision_status' => 'FAIL_INSTANCE_PROVISIONING',
          },
          {
            'name' => 'd-trac-yggdrasil-01',
            'type' => 'yggdrasil',
            'node_container_config' => 'medium',
            'provision_status' => 'UNPROCESSED',
          }
        ]
      end
    end
  end
end
