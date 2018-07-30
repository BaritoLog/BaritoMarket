require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe RetryBootstrapWorker, type: :worker do
  before(:each) do
    Sidekiq::Worker.clear_all
    @infrastructure = create(:infrastructure)
  end

  describe 'worker queueing' do
    it 'enqueues a retry bootstrap worker' do
      expect {
        RetryBootstrapWorker.perform_async(@infrastructure.id, 2)
      }.to change(RetryBootstrapWorker.jobs, :size).by(1)
    end
  end
end
