require 'rails_helper'

RSpec.describe AppGroupTeam, type: :model do
  it 'has relation with app group' do
    app_group = create(:app_group)
    app_group_team = create(:app_group_team, app_group: app_group)
    expect(app_group_team.app_group).to eq(app_group)
  end

  it 'has relation with app group role' do
    app_group_role = create(:app_group_role)
    app_group_team = create(:app_group_team, role: app_group_role)
    expect(app_group_team.role).to eq(app_group_role)
  end

  it 'has relation with group' do
    group = create(:group)
    app_group_team = create(:app_group_team, group: group)
    expect(app_group_team.group).to eq(group)
  end
end
