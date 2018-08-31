require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe ProvisioningCheckWorker, type: :worker do
  before(:each) do
    Sidekiq::Worker.clear_all
    @infrastructure_component = create(:infrastructure_component)
  end

  describe 'worker queueing' do
    it 'enqueues a provisioning check worker' do
      expect {
        ProvisioningCheckWorker.perform_async(@infrastructure_component.id)
      }.to change(ProvisioningCheckWorker.jobs, :size).by(1)
    end
  end
end
