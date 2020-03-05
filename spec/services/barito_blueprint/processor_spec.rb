require 'rails_helper'

module BaritoBlueprint
  RSpec.describe Processor do
    before(:each) do
      @infrastructure = create(:infrastructure)
      @processor = Processor.new(
        infrastructure_id: @infrastructure.id,
        chef_repo_dir: Figaro.env.chef_repo_dir,
      )

    end

    describe '#process!' do
      before(:each) do
        provisioner = double
        allow(provisioner).to(receive(:bulk_apply!).
          and_return(true))
        allow(Provisioner).to receive(:new).and_return(provisioner)

        bootstrapper = double
        allow(bootstrapper).to(receive(:generate_manifests!).and_return(true))
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
