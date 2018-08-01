require 'rails_helper'

module BaritoBlueprint
  RSpec.describe Processor do
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
      @processor = Processor.new(
        @blueprint_hash, chef_repo_dir: Figaro.env.chef_repo_dir)
    end

    describe '#process!' do
      before(:each) do
        provisioner = double
        allow(provisioner).to(receive(:provision_instances!).and_return true)
        allow(provisioner).to(
          receive(:check_and_update_instances).and_return true)
        allow(Provisioner).to receive(:new).and_return(provisioner)

        bootstrapper = double
        allow(bootstrapper).to(receive(:bootstrap_instances!).and_return true)
        allow(Bootstrapper).to receive(:new).and_return(bootstrapper)
      end

      it 'should save consul_host when the process is finished' do
        @processor.process!
        @infrastructure.reload
        expect(@infrastructure.consul_host).not_to eq nil
      end
    end
  end
end
