require 'rails_helper'

RSpec.describe Databag, type: :model do

  context 'ip_address' do
    it 'must be presence' do
      service_config = FactoryGirl.build(:databag, ip_address: '')
      expect(service_config).to_not be_valid
    end
  end

  context 'config_json' do
    it 'must be presence' do
      service_config = FactoryGirl.build(:databag, config_json: nil)
      expect(service_config).to_not be_valid
    end
  end

  context 'tags' do
    it 'must be presence' do
      service_config = FactoryGirl.build(:databag, tags: '')
      expect(service_config).to_not be_valid
    end
  end
end
