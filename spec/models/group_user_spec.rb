require 'rails_helper'

RSpec.describe GroupUser, type: :model do
  let(:role) { create(:app_group_role) }

  it 'has relation with role' do
    group_user = create(:group_user, role: role)
    expect(group_user.role).to eq(role)
  end
end
