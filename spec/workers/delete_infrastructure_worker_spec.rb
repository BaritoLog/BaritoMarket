require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe DeleteInfrastructureWorker, type: :worker do
  before(:each) do
    Sidekiq::Worker.clear_all
    @infrastructure = create(:infrastructure)
  end

  describe 'worker queueing' do
    it 'enqueues a retry bootstrap worker' do
      expect {
        DeleteInfrastructureWorker.perform_async(@infrastructure.id)
      }.to change(DeleteInfrastructureWorker.jobs, :size).by(1)
    end
  end
end
