require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe RetryProvisionWorker, type: :worker do
  before(:each) do
    Sidekiq::Worker.clear_all
    @infrastructure_component = create(:infrastructure_component)
  end

  describe 'worker queueing' do
    it 'enqueues a retry bootstrap worker' do
      expect {
        RetryProvisionWorker.perform_async(@infrastructure_component.id)
      }.to change(RetryProvisionWorker.jobs, :size).by(1)
    end
  end
end
