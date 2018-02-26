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

end
