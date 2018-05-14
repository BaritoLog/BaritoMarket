require 'rails_helper'

RSpec.describe ChefConfigs, type: :model do
  context 'config' do
    it 'must be presence' do
      chef_configs = FactoryBot.build(:chef_configs)
      expect(chef_configs.config).to_not be_nil
    end

    it 'fetch by id' do
      chef_configs = FactoryBot.build(:chef_configs)
      expect(chef_configs.get('some-instance')).to_not be_nil
    end
  end

end
