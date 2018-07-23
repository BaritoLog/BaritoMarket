require 'rails_helper'

RSpec.feature 'Application Group Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:admin) { create(:user) }

  before(:each) do
    @app_group_a = create(:app_group, created_by: user_a)
    @app_group_b = create(:app_group, created_by: user_b)

    [@app_group_a, @app_group_b].each { |app_group| create(:infrastructure, app_group: app_group) }
  end

  describe 'Managing Access', js: true do
    context 'As Owner or Superadmin' do
      scenario 'User can add members to app group' do
        set_check_user_groups({ 'groups' => 'barito-superadmin' })
        create(:group, name: 'barito-superadmin')
        create(:app_group_role)
        login_as admin

        visit root_path
        click_link @app_group_a.name

        click_link 'Manage Access'
        set_select2_option(selector: '#assign_member_user_id', text: user_b.username, value: user_b.id)
        find('form#new_app_group_user input[value="Add"]').click

        expect(page).to have_content("#{user_b.username} - #{user_b.email}")
        expect(page).to have_css("a[href='#{app_group_user_path(user_id: user_b.id, app_group_id: @app_group_a.id)}']")
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with role admin cannot manage access but can add/delete barito app' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :admin), user: user_b)

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).not_to have_content('Manage Access')
        expect(page).to have_css("form#new_barito_app")
      end

      scenario 'User with role "owner" can do just like owner/superadmin' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :owner), user: user_b)

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).to have_content('Manage Access')
        expect(page).to have_css("form#new_barito_app")
      end
    end
  end
end
