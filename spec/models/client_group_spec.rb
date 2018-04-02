require 'rails_helper'

RSpec.describe ClientGroup, type: :model do
  context 'associations' do
    it 'belong to user group' do
      assc = described_class.reflect_on_association(:user_group)
      expect(assc.macro).to eq :belongs_to
    end

    it 'belong to client' do
      assc = described_class.reflect_on_association(:client)
      expect(assc.macro).to eq :belongs_to
    end
  end
end