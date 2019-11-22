require 'rails_helper'

RSpec.describe AppGroupTeam, type: :model do
  let(:app_group) { create(:app_group) }

  it 'has relation with app group' do
    app_group_team = create(:app_group_team, app_group: app_group)
    expect(app_group_team.app_group).to eq(app_group)
  end

  let(:role) { create(:app_group_role) }

  it 'has relation with app group role' do
    app_group_team = create(:app_group_team, role: role)
    expect(app_group_team.role).to eq(role)
  end

  let(:group) { create(:group) }

  it 'has relation with group' do
    app_group_team = create(:app_group_team, group: group)
    expect(app_group_team.group).to eq(group)
  end

  context 'validation' do
    it 'rejects adding two same group in an app group' do
      create(:app_group_team, app_group: app_group, group: group)
      expect(build(:app_group_team, app_group: app_group, group: group)).not_to be_valid
    end

    it 'should check presence of app group' do
      expect(build(:app_group_team, app_group: nil)).not_to be_valid
    end

    it 'should check presence of role' do
      expect(build(:app_group_team, role: nil)).not_to be_valid
    end
  end
end
