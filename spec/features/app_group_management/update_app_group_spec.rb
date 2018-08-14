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

  describe 'Edit metadata' do
    context 'As Superadmin' do
      scenario 'User can edit the app group metadata', js: true do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        create(:app_group_role)
        login_as admin

        visit root_path
        click_link @app_group_a.name

        expect(page).to have_css("input#app_group_name[value='#{@app_group_a.name}']")

        fill_in "app_group_name", with: "new_#{@app_group_a.name}"
        find("input#app_group_name").native.send_keys :enter
        expect(page).to have_css("input#app_group_name[value='new_#{@app_group_a.name}']")
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with role "owner" or "admin" can edit app groups metadata', js: true do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :admin), user: user_b)

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).to have_css("input#app_group_name[value='#{@app_group_a.name}']")

        fill_in "app_group_name", with: "new_#{@app_group_a.name}"
        find("input#app_group_name").native.send_keys :enter
        expect(page).to have_css("input#app_group_name[value='new_#{@app_group_a.name}']")
      end

      scenario 'User with role "member" cannot edit the app groups metadata', js: true do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role), user: user_b)

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).not_to have_css('input#app_group_name')
      end
    end
  end
end
