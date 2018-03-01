require 'rails_helper'

RSpec.describe Databag, type: :model do

  context 'ip_address' do
    it 'must be presence' do
      databag = FactoryGirl.build(:databag, ip_address: '')
      expect(databag).to_not be_valid
    end
  end

  context 'config_json' do
    it 'must be presence' do
      databag = FactoryGirl.build(:databag, config_json: nil)
      expect(databag).to_not be_valid
    end
  end

  context 'tags' do
    it 'must be presence' do
      databag = FactoryGirl.build(:databag, tags: '')
      expect(databag).to_not be_valid
    end
  end
end
