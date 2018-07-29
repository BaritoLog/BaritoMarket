require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe BlueprintProcessor do
  context 'worker queueing' do
    it 'enqueues a blueprint worker' do
      expect {
        BlueprintWorker.
          perform_async('blueprints/jobs/abcd_20180101111111.json')
      }.to change(BlueprintWorker.jobs, :size).by(1)
    end
  end
  context 'Blueprint worker' do
    it 'should start a blueprint worker successfully' do
      expect {
        BlueprintWorker.new.perform('blueprints/jobs/abcd_20180101111111.json')
      }.not_to raise_error
    end
  end
end
