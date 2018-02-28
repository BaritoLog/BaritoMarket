require 'rails_helper'

RSpec.describe Service, type: :model do

  context 'associations' do
    it 'belongs to group' do
      assc = described_class.reflect_on_association(:group)
      expect(assc.macro).to eq :belongs_to
    end

    it 'belongs to store' do
      assc = described_class.reflect_on_association(:store)
      expect(assc.macro).to eq :belongs_to
    end

    it 'belongs to forwarder' do
      assc = described_class.reflect_on_association(:forwarder)
      expect(assc.macro).to eq :belongs_to
    end
  end

  context 'name' do
    it 'must be presence' do
      group = FactoryGirl.build(:forwarder, name: '')
      expect(group).to_not be_valid
    end
  end

  context 'when service created' do
    it 'copy kafka topics from forwarder' do
      service = FactoryGirl.create(:service)
      expect(service.kafka_topics).to eq(service.forwarder.kafka_topics)
    end

    it 'generate produce url' do
      group = FactoryGirl.create(:group, id: 1, receiver_host: 'some-host:with-port')
      store = FactoryGirl.create(:store, id: 2)
      forwarder = FactoryGirl.create(:forwarder, id: 3, kafka_topics: 'kafka-topics')
      service = FactoryGirl.create(:service, group: group, store: store, forwarder: forwarder, id: 4)

      expect(service.produce_url).to eq('http://some-host:with-port/gp/1/st/2/fw/3/sv/4/produce/kafka-topics')
    end

    it 'setup forwarder' do
      service = FactoryGirl.create(:service)
      expect(service.group).to eq(service.forwarder.group)
      expect(service.store).to eq(service.forwarder.store)
    end

    it 'copy kibana host from store' do
      service = FactoryGirl.create(:service)
      expect(service.kibana_host).to eq(service.store.kibana_host)
    end

    it 'copy kafka topic partition from group' do
      service = FactoryGirl.create(:service)
      expect(service.kafka_topic_partition).to eq(service.group.kafka_topic_partition)
    end
  end

end
