require 'rails_helper'

RSpec.feature 'Application Group Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:admin) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    @app_group_a = create(:app_group)

    [@app_group_a].each { |app_group| create(:infrastructure, app_group: app_group) }
  end

  describe 'Managing Access', js: true do
    context 'As Superadmin' do
      scenario 'User can add members to app group' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        create(:app_group_role)
        [:admin, :owner].each { |role| create(:app_group_role, role) }
        login_as admin

        visit root_path
        click_link @app_group_a.name

        click_link 'Manage Access'
        set_select2_option(selector: '#assign_member_user_id', text: user_b.email, value: user_b.id)
        find('form#new_app_group_user input[value="Add"]').click

        expect(page).to have_content(user_b.email)
        expect(page).to have_css("a[href='#{app_group_user_path(user_id: user_b.id, app_group_id: @app_group_a.id)}']")
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with role "admin" cannot manage access but can add/delete barito app' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :admin), user: user_b)

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).not_to have_content('Manage Access')
        expect(page).to have_css("form#new_barito_app", visible: false)
      end

      scenario 'User with role "owner" can do just like superadmin' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :owner), user: user_b)

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).to have_content('Manage Access')
        expect(page).to have_css('form#new_barito_app', visible: false)
      end
    end
  end

  describe 'Set Role', js: true do
    context 'When set to only specific AppGroup' do
      scenario 'Should only set to specifc AppGroup' do
        @app_group_b = create(:app_group)
        create(:infrastructure, app_group: @app_group_b)
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        create(:app_group_role)
        [:admin, :owner].each { |role| create(:app_group_role, role) }

        login_as admin

        visit root_path
        click_link @app_group_a.name

        click_link 'Manage Access'
        set_select2_option(selector: '#assign_member_user_id', text: user_a.email, value: user_a.id)
        find('form#new_app_group_user input[value="Add"]').click

        expect(page).to have_content(user_a.email)
        expect(page).to have_css("a[href='#{app_group_user_path(user_id: user_a.id, app_group_id: @app_group_a.id)}']")

        visit root_path
        click_link @app_group_b.name

        click_link 'Manage Access'
        expect(page).not_to have_content(user_a.email)
        expect(page).not_to have_css("a[href='#{app_group_user_path(user_id: user_a.id, app_group_id: @app_group_a.id)}']")
      end
    end

    context 'Removing access to user' do
      scenario 'Not removing User access in another AppGroup' do
        @app_group_b = create(:app_group)
        create(:infrastructure, app_group: @app_group_b)
        member_role = create(:app_group_role)
        [:admin, :owner].each { |role| create(:app_group_role, role) }

        [@app_group_a, @app_group_b].each do |app_group|
          create(:app_group_user, app_group: app_group, role: member_role, user: user_a)
          create(:app_group_user, app_group: app_group, role: member_role, user: user_b)
        end

        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')

        login_as admin

        visit root_path
        click_link @app_group_a.name
        click_link 'Manage Access'
        find("a[href='/app_group_users/#{user_a.id}/delete/#{@app_group_a.id}']").click

        expect(page).not_to have_content(user_a.email)

        visit root_path
        click_link @app_group_b.name
        click_link 'Manage Access'

        expect(page).to have_content(user_a.email)
      end
    end

    scenario 'User only have one Role' do
      admin_role = create(:app_group_role, :admin)
      create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role), user: user_b)
      create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :owner), user: user_a)
      login_as user_a

      visit root_path
      click_link @app_group_a.name
      click_link 'Manage Access'

      expect(page).to have_content(user_b.email)
      user_b_app_group_user = user_b.app_group_users.first
      expect(user_b.app_group_users.first.role.name).to eq 'member'
      find("a[href='#{set_role_app_group_user_path(user_id: user_b.id, role_id: admin_role, app_group_id: @app_group_a.id)}']").click

      expect(user_b.app_group_users.reload.first.role.name).to eq 'admin'
    end
  end
end
