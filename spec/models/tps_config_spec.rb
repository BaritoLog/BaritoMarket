require 'rails_helper'

RSpec.describe TpsConfig, type: :model do
  context 'config' do
    it 'must be presence' do
      tps_config = FactoryBot.build(:tps_config)
      expect(tps_config.config).to_not be_nil
    end

    it 'fetch by id' do
      tps_config = FactoryBot.build(:tps_config)
      expect(tps_config.get('small')).to_not be_nil
    end

    it 'has name property by id' do
      tps_config = FactoryBot.build(:tps_config)
      expect(tps_config.name('small')).to eq('Small')
    end
  end

end
