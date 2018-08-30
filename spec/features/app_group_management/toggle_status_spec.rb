require 'rails_helper'

RSpec.feature 'Application Group Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    @app_group_a = create(:app_group)

    [@app_group_a].each { |app_group| create(:infrastructure, app_group: app_group) }
  end

  describe 'Toggle Status AppGroup or Infrastructure' do
    context 'As Superadmin' do
      scenario 'User can toggle AppGroup or Infrastructure status', js: true do
        set_check_user_groups({ 'groups' => 'barito-superadmin' })
        create(:group, name: 'barito-superadmin')
        login_as user_a

        visit root_path
        expect(page).to have_content(@app_group_a.name)
        expect(@app_group_a.infrastructure.status).to eq Infrastructure.statuses[:inactive]

        page.execute_script("$('#toggle_infra_status_#{@app_group_a.id}').prop('checked', true).change();")
        expect(@app_group_a.infrastructure.reload.status).to eq Infrastructure.statuses[:active]
      end
    end

    context 'As Authorized Use based on Role' do
      scenario 'User with role other than "superadmin" are not allowed to change app group status', js: true do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :admin), user: user_b)

        login_as user_b

        visit root_path

        expect(page).not_to have_css("#toggle_infra_status_#{@app_group_a.id}")
      end
    end
  end
end
