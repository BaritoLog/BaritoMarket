require 'rails_helper'

RSpec.describe AppGroupTeam, type: :model do
  it 'has relation with app group' do
    app_group = create(:app_group)
    app_group_team = create(:app_group_team, app_group: app_group)
    expect(app_group_team.app_group).to eq(app_group)
  end
end
