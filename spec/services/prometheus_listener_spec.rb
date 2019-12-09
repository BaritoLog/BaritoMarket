require 'rails_helper'

require 'prometheus/middleware/collector'

RSpec.describe PrometheusListener do
  let(:registry) { Prometheus::Client::Registry.new }

  let!(:listener) { described_class.new(registry) }

  let(:app_group) { create(:app_group) }
  let!(:app) { create(:barito_app, app_group: app_group, log_count: 10) }

  describe 'per-app metrics' do
    let(:labels) do
      {
        app_group: app_group.name,
        app_name: app.name,
        environment: app_group.environment,
      }
    end

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

  describe 'team-related metrics' do
    before do
      create(:infrastructure, app_group: app_group)
      create(:infrastructure, app_group: app_group, provisioning_status: 'DELETED')
    end

    describe 'app_count metrics' do
      subject { registry.get(:barito_market_app_count) }

      it 'should be in registry' do
        expect(subject).to be_a(Prometheus::Client::Gauge)
      end

      it 'should report current app count' do
        listener.app_count_changed
        expect(subject.get).to eq(1.0)
      end
    end

    describe 'team_count metrics' do
      subject { registry.get(:barito_market_team_count) }

      it 'should be in registry' do
        expect(subject).to be_a(Prometheus::Client::Gauge)
      end

      it 'should report current team count' do
        listener.team_count_changed
        expect(subject.get).to eq(1.0)
      end
    end
  end
end
