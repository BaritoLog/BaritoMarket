require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe RetryBootstrapWorker, type: :worker do
  before(:each) do
    Sidekiq::Worker.clear_all
    @infrastructure = create(:infrastructure)
    @infrastructure_components = @infrastructure.infrastructure_components
  end
  context 'worker queueing' do
    it 'enqueues a retry bootstrap worker' do
      expect {
        RetryBootstrapWorker.
          perform_async(2, @infrastructure.id)
      }.to change(RetryBootstrapWorker.jobs, :size).by(1)
    end
  end
  context 'Retry bootstrap worker' do
    it 'should start a retry bootstrap worker successfully' do
      expect {
        RetryBootstrapWorker.new.perform(2, @infrastructure.id)
      }.not_to raise_error
    end
    it 'should start a retry bootstrap worker raise_error' do
      not_exist_infrastructure_id = 15
      expect {
        RetryBootstrapWorker.new.perform(2, not_exist_infrastructure_id)
      }.to raise_error(message="Exception: Couldn't find Infrastructure with 'id'=15")
    end
  end
end
