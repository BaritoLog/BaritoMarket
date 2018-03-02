require 'rails_helper'

RSpec.describe Stream, type: :model do

  context 'name' do
    it 'must be presence' do
      group = FactoryGirl.build(:stream, name: '')
      expect(group).to_not be_valid
    end
  end

  context 'receiver_host' do
    it 'must be presence' do
      group = FactoryGirl.build(:stream, receiver_host: '')
      expect(group).to_not be_valid
    end
  end

  context 'zookeeper_hosts' do
    it 'must be presence' do
      group = FactoryGirl.build(:stream, zookeeper_hosts: '')
      expect(group).to_not be_valid
    end
  end

  context 'kafka_broker_hosts' do
    it 'must be presence' do
      group = FactoryGirl.build(:stream, kafka_broker_hosts: '')
      expect(group).to_not be_valid
    end
  end

  context 'kafka_topic_partition' do
    it 'must be presence' do
      group = FactoryGirl.build(:stream, kafka_topic_partition: nil)
      expect(group).to_not be_valid
    end

    it 'greater than or equal to kafka broker host number' do
      group = FactoryGirl.build(:stream, kafka_broker_hosts: 'host,host2', kafka_topic_partition: 1)
      expect(group).to_not be_valid
    end
  end

  context 'receiver_port' do
    it 'must be presence' do
      group = FactoryGirl.build(:stream, receiver_port: '')
      expect(group).to_not be_valid
    end
  end

  context 'when group created' do
    it 'create receiver config' do
      group = FactoryGirl.create(:stream)

      databag = Databag.find(group.databag_id)

      expect(databag.data['kafka_broker_hosts']).to eq(group.kafka_broker_hosts)
      expect(databag.data['zookeeper_hosts']).to eq(group.zookeeper_hosts)
      expect(databag.data['receiver_port']).to eq(group.receiver_port)
    end
  end

end
