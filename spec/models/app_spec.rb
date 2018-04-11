require 'rails_helper'

RSpec.describe App, type: :model do
  context 'associations' do
    it 'belongs to app_group' do
      assc = described_class.reflect_on_association(:app_group)
      expect(assc.macro).to eq :belongs_to
    end
    
    it 'belongs to log_template' do
      assc = described_class.reflect_on_association(:log_template)
      expect(assc.macro).to eq :belongs_to
    end
  end
  
  context 'name' do
    it 'must be presence' do
      app = FactoryBot.build(:app, name: '')
      expect(app).to_not be_valid
    end
  end
end
