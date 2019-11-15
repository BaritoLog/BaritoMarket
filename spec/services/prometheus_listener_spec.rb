require 'rails_helper'

require 'prometheus/middleware/collector'

RSpec.describe PrometheusListener do
  let(:registry) { Prometheus::Client::Registry.new }

  let!(:listener) { described_class.new(registry) }

  it 'should have log_count metrics' do
    expect(registry.get(:barito_market_log_count)).to be_a(Prometheus::Client::Gauge)
  end

  let(:app_group) { create(:app_group) }
  let!(:app) { create(:barito_app, app_group: app_group, log_count: 10) }
  let!(:infrastructure1) { create(:infrastructure, app_group: app_group) }
  let!(:infrastructure2) { create(:infrastructure, app_group: app_group, provisioning_status: "DELETED") }

  it 'should change whenever log count is changed' do
    listener.log_count_changed(app.id, 0)

    expect(registry.get(:barito_market_log_count).get(labels: {
      app_group: app.app_group.name, app_name: app.name
    })).to eq(app.log_count)
  end

  it 'should have log_throughput metrics' do
    expect(registry.get(:barito_market_log_throughput)).to be_a(Prometheus::Client::Gauge)
  end

  it 'should change whenever log throughput is changed' do
    listener.log_count_changed(app.id, 2000.0)

    expect(registry.get(:barito_market_log_throughput).get(labels: {
      app_group: app.app_group.name, app_name: app.name
    })).to eq(2000.0)
  end

  it 'should have app_count metrics' do
    expect(registry.get(:barito_market_app_count)).to be_a(Prometheus::Client::Gauge)
  end

  it 'should report current app count' do
    listener.app_count_changed
    expect(registry.get(:barito_market_app_count).get).to eq(1.0)
  end

  it 'should have team_count metrics' do
    expect(registry.get(:barito_market_team_count)).to be_a(Prometheus::Client::Gauge)
  end
end
