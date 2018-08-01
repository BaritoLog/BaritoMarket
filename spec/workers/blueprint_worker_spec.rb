require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe BlueprintWorker do
  describe 'worker queueing' do
    it 'enqueues a blueprint worker' do
      expect {
        BlueprintWorker.
          perform_async('blueprints/jobs/abcd_20180101111111.json')
      }.to change(BlueprintWorker.jobs, :size).by(1)
    end
  end
end
