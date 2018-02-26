require 'rails_helper'

RSpec.describe Forwarder, type: :model do

  context 'associations' do
    it 'belongs to group' do
      assc = described_class.reflect_on_association(:group)
      expect(assc.macro).to eq :belongs_to
    end

    it 'belongs to store' do
      assc = described_class.reflect_on_association(:store)
      expect(assc.macro).to eq :belongs_to
    end
  end

  context 'name' do
    it 'must be presence' do
      group = FactoryGirl.build(:forwarder, name: '')
      expect(group).to_not be_valid
    end
  end

  context 'host' do
    it 'must be presence' do
      group = FactoryGirl.build(:forwarder, host: '')
      expect(group).to_not be_valid
    end
  end

  context 'kafka_topics' do
    it 'must be presence' do
      group = FactoryGirl.build(:forwarder, kafka_topics: '')
      expect(group).to_not be_valid
    end
  end

  it 'copy kafka broker & zookeeper hosts from group' do
    forwarder = FactoryGirl.create(:forwarder)
    expect(forwarder.kafka_broker_hosts).to eq(forwarder.group.kafka_broker_hosts)
    expect(forwarder.zookeeper_hosts).to eq(forwarder.group.zookeeper_hosts)

    new_hosts = 'new-hosts'
    new_hosts_2 = 'new-hosts-2'

    group = FactoryGirl.create(:group, kafka_broker_hosts: new_hosts, zookeeper_hosts: new_hosts_2)
    forwarder.group = group
    forwarder.save

    expect(forwarder.kafka_broker_hosts).to eq(new_hosts)
    expect(forwarder.zookeeper_hosts).to eq(new_hosts_2)
  end

end
