require 'rails_helper'

RSpec.describe LogTemplate, type: :model do
  
  context 'name' do
    it 'must be presence' do
      template = FactoryBot.build(:log_template, name: '')
      expect(template).to_not be_valid
    end
  end
  
  context 'tps_limit' do
    it 'must be presence' do
      template = FactoryBot.build(:log_template, tps_limit: nil)
      expect(template).to_not be_valid
    end
    it 'must greater than 0' do
      template = FactoryBot.build(:log_template, tps_limit: 0)
      expect(template).to_not be_valid
    end
  end
  
  context 'zookeeper_instances' do
    it 'must be presence' do
      template = FactoryBot.build(:log_template, zookeeper_instances: nil)
      expect(template).to_not be_valid
    end
    
  end
  
  context 'kafka_instances' do
    it 'must be presence' do
      template = FactoryBot.build(:log_template, kafka_instances: nil)
      expect(template).to_not be_valid
    end
    
  end
  
  context 'es_instances' do
    it 'must be presence' do
      template = FactoryBot.build(:log_template, es_instances: nil)
      expect(template).to_not be_valid
    end
  end
  
  describe '.name_with_tps' do
    it do
      template = FactoryBot.build(:log_template)
      expect(template.name_with_tps).to eq('Template1 (1 trx/sec)')
    end
  end
  
end
