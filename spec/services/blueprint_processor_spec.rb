require 'rails_helper'

RSpec.describe BlueprintProcessor do
  before(:each) do
    @blueprint_hash = {
      'application_id' => 1,
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
    context 'using SauronProvisioner' do
      it 'should populate nodes based on return value from provisioner' do
        # Mock sauron_provisioner
        sauron_provisioner = double
        allow(sauron_provisioner).to receive(:provision!).and_return({
          'success' => true,
          'data' => {
            'ip_address' => 'xx.yy.zz.hh',
            'access_key' => 'barito'
          }       
        })
        allow(SauronProvisioner).to receive(:new).and_return(sauron_provisioner)

        blueprint_processor = BlueprintProcessor.new(@blueprint_hash)
        blueprint_processor.process!
        expect(blueprint_processor.nodes).to eq [
          {
            'name' => 'd-trac-consul-01',
            'type' => 'consul',
            'node_container_config' => 'medium',
            'provision_status' => 'INSTANCE_PROVISIONED',
            'provision_attributes' => {
              'ip_address' => 'xx.yy.zz.hh',
              'access_key' => 'barito'
            }
          },
          {
            'name' => 'd-trac-yggdrasil-01',
            'type' => 'yggdrasil',
            'node_container_config' => 'medium',
            'provision_status' => 'INSTANCE_PROVISIONED',
            'provision_attributes' => {
              'ip_address' => 'xx.yy.zz.hh',
              'access_key' => 'barito'
            }
          }
        ]
      end

      it 'should populate nodes as failed if provisioning fails' do
        # Mock sauron_provisioner
        sauron_provisioner = double
        allow(sauron_provisioner).to receive(:provision!).and_return({
          'success' => false,
          'error' => '',         
        })
        allow(SauronProvisioner).to receive(:new).and_return(sauron_provisioner)

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
            'provision_status' => 'FAIL_INSTANCE_PROVISIONING',
          }
        ]
      end
    end
  end
end
