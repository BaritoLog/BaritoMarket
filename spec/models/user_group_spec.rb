require 'rails_helper'

RSpec.describe UserGroup, type: :model do
  context 'name' do
    it 'must be presence' do
      user_group = FactoryBot.build(:user_group, name: '')
      expect(user_group).to_not be_valid
    end
  end

  context 'associations' do
    it 'has many client group' do
      assc = described_class.reflect_on_association(:client_groups)
      expect(assc.macro).to eq :has_many
    end

    it 'has many client' do
      assc = described_class.reflect_on_association(:clients)
      expect(assc.macro).to eq :has_many
    end
  end
end
