require 'rails_helper'

RSpec.describe Group, type: :model do

  context 'name' do
    it 'must be presence' do
      group = FactoryGirl.build(:group, name: '')
      expect(group).to_not be_valid
    end
  end

  context 'receiver_host' do
    it 'must be presence' do
      group = FactoryGirl.build(:group, receiver_host: '')
      expect(group).to_not be_valid
    end
  end

  context 'zookeeper_hosts' do
    it 'must be presence' do
      group = FactoryGirl.build(:group, zookeeper_hosts: '')
      expect(group).to_not be_valid
    end
  end

  context 'kafka_broker_hosts' do
    it 'must be presence' do
      group = FactoryGirl.build(:group, kafka_broker_hosts: '')
      expect(group).to_not be_valid
    end
  end

  context 'kafka_topic_partition' do
    it 'must be presence' do
      group = FactoryGirl.build(:group, kafka_topic_partition: nil)
      expect(group).to_not be_valid
    end
  end

end
