require 'rails_helper'

RSpec.describe Forwarder, type: :model do

  context 'associations' do
    it 'belongs to stream' do
      assc = described_class.reflect_on_association(:stream)
      expect(assc.macro).to eq :belongs_to
    end

    it 'belongs to store' do
      assc = described_class.reflect_on_association(:store)
      expect(assc.macro).to eq :belongs_to
    end
  end

  context 'name' do
    it 'must be presence' do
      forwarder = FactoryBot.build(:forwarder, name: '')
      expect(forwarder).to_not be_valid
    end
  end

  context 'host' do
    it 'must be presence' do
      forwarder = FactoryBot.build(:forwarder, host: '')
      expect(forwarder).to_not be_valid
    end
  end

  context 'kafka_topics' do
    it 'must be presence' do
      forwarder = FactoryBot.build(:forwarder, kafka_topics: '')
      expect(forwarder).to_not be_valid
    end
  end

  describe '#set_stream_and_store' do
    it 'set stream, store, kafka_broker_hosts, and zookeeper_hosts' do
      stream = FactoryBot.build(:stream, kafka_broker_hosts: 'broker-host', zookeeper_hosts: 'zookeeper-host')
      store = FactoryBot.build(:store)
      forwarder = FactoryBot.build(:forwarder)

      forwarder.set_stream_and_store(stream, store)

      expect(forwarder.stream).to eq(stream)
      expect(forwarder.store).to eq(store)

      expect(forwarder.kafka_broker_hosts).to eq('broker-host')
      expect(forwarder.zookeeper_hosts).to eq('zookeeper-host')
    end
  end

end
