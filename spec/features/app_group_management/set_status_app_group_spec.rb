require 'rails_helper'

RSpec.feature 'Application Group Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:admin) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    @app_group_a = create(:app_group)
    create(:infrastructure, app_group: @app_group_a)
  end

  describe 'Toggle Status' do
    context 'As Superadmin' do
      scenario 'User can toggle status app group', js: true do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        create(:app_group_role)
        login_as admin

        visit root_path

        expect(page).to have_css("select#toggle_status")
        expect(find('select#toggle_status').value).to eq 'INACTIVE'

        select('active', from: 'toggle_status')
        expect(AppGroup.first.infrastructure.status).to eq 'ACTIVE'
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with role other than "superadmin" are not allowed to change app group status', js: true do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :admin), user: user_b)

        login_as user_b

        visit root_path

        expect(page).not_to have_css("select#toggle_status")
      end
    end
  end
end
