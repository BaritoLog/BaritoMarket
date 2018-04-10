require 'rails_helper'

RSpec.describe Store, type: :model do

  context 'name' do
    it 'must be presence' do
      store = FactoryBot.build(:store, name: '')
      expect(store).to_not be_valid
    end
  end

  context 'elasticsearch_host' do
    it 'must be presence' do
      store = FactoryBot.build(:store, elasticsearch_host: '')
      expect(store).to_not be_valid
    end
  end

  context 'kibana_host' do
    it 'must be presence' do
      store = FactoryBot.build(:store, kibana_host: '')
      expect(store).to_not be_valid
    end
  end

end
