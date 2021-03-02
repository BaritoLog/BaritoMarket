require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe HelmSyncWorker, type: :worker do
  before(:each) do
    Sidekiq::Worker.clear_all
    @helm_infrastructure = create(:helm_infrastructure)
  end

  describe 'worker queueing' do
    it 'enqueues a retry bootstrap worker' do
      expect {
        HelmSyncWorker.perform_async(@helm_infrastructure.id)
      }.to change(HelmSyncWorker.jobs, :size).by(1)
    end
  end
end
