require 'rails_helper'

require 'prometheus/middleware/collector'

RSpec.describe PrometheusListener do
  let(:registry) { Prometheus::Client::Registry.new }

  let!(:listener) { described_class.new(registry) }

  let(:app_group) { create(:app_group) }
  let!(:app) { create(:barito_app, app_group: app_group, log_count: 10) }
  let!(:infrastructure1) { create(:infrastructure, app_group: app_group) }
  let!(:infrastructure2) { create(:infrastructure, app_group: app_group, provisioning_status: "DELETED") }

  describe 'per-app metrics' do
    let(:labels) { { app_group: app.app_group.name, app_name: app.name } }

    describe 'log_count metrics' do
      subject { registry.get(:barito_market_log_count) }

      it 'should be in registry' do
        expect(subject).to be_a(Prometheus::Client::Gauge)
      end

      it 'should be updated whenever log count is changed' do
        listener.log_count_changed(app.id, 0)
        expect(subject.get(labels: labels)).to eq(app.log_count)
      end
    end

    describe 'log_throughput metrics' do
      subject { registry.get(:barito_market_log_throughput) }

      it 'should be in registry' do
        expect(subject).to be_a(Prometheus::Client::Gauge)
      end

      it 'should be updated whenever log throughput is changed' do
        listener.log_count_changed(app.id, 2000.0)
        expect(subject.get(labels: labels)).to eq(2000.0)
      end
    end
  end

  describe 'app_count metrics' do
    subject { registry.get(:barito_market_app_count) }

    it 'should be in registry' do
      expect(subject).to be_a(Prometheus::Client::Gauge)
    end
  end

  describe 'team_count metrics' do
    subject { registry.get(:barito_market_team_count) }

    it 'should be in registry' do
      expect(subject).to be_a(Prometheus::Client::Gauge)
    end
  end

  it 'should report current app count' do
    listener.app_count_changed
    expect(registry.get(:barito_market_app_count).get).to eq(1.0)
  end

  it 'should report current team count' do
    listener.team_count_changed
    expect(registry.get(:barito_market_team_count).get).to eq(1.0)
  end
end
