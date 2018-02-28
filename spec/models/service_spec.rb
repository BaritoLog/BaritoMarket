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
  end

end
