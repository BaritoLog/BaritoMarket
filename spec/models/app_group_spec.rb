require 'rails_helper'

RSpec.describe AppGroup, type: :model do
  context 'name' do
    it 'must be presence' do
      group = FactoryBot.build(:app_group, name: '')
      expect(group).to_not be_valid
    end
  end
end
