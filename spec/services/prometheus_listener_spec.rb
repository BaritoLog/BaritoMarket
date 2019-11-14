require 'rails_helper'

require 'prometheus/middleware/collector'

RSpec.describe PrometheusListener do
  let(:registry) { Prometheus::Client::Registry.new }

  let!(:listener) { described_class.new(registry) }

  it 'should have log_count metrics' do
    expect(registry.get(:barito_market_log_count)).to be_a(Prometheus::Client::Gauge)
  end
end
