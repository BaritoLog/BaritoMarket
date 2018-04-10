require 'rails_helper'

RSpec.describe Databag, type: :model do

  context 'ip_address' do
    it 'must be presence' do
      databag = FactoryBot.build(:databag, ip_address: '')
      expect(databag).to_not be_valid
    end
  end

  context 'data' do
    it 'must be presence' do
      databag = FactoryBot.build(:databag, data: nil)
      expect(databag).to_not be_valid
    end
  end

  context 'tags' do
    it 'must be presence' do
      databag = FactoryBot.build(:databag, tags: '')
      expect(databag).to_not be_valid
    end
  end
end
