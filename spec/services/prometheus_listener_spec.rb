require 'rails_helper'

require 'prometheus/middleware/collector'

RSpec.describe PrometheusListener do
  let(:registry) { Prometheus::Client::Registry.new }

  let!(:listener) { described_class.new(registry) }

  it 'should have log_count metrics' do
    expect(registry.get(:barito_market_log_count)).to be_a(Prometheus::Client::Gauge)
  end

  let(:app) { create(:barito_app) }

  it 'should change whenever log count is changed' do
    listener.log_count_changed(app.id, 0)

    expect(registry.get(:barito_market_log_count).get(labels: {
      app_group: app.app_group.name, app_name: app.name
    })).to eq(app.log_count)
  end
end
