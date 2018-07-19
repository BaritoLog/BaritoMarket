require 'rails_helper'

RSpec.feature 'Application Group Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:admin) { create(:user, :admin) }

  before(:each) do
    @app_group_a = create(:app_group, created_by: user_a)
    @app_group_b = create(:app_group, created_by: user_b)

    [@app_group_a, @app_group_b].each { |app_group| create(:infrastructure, app_group: app_group) }
  end

  describe 'View applications group lists' do

    context 'As Owner/Superadmin' do
      scenario 'User can only see app group that they created' do
        login_as user_a

        visit root_path
        expect(page).to have_content(@app_group_a.name)
        expect(page).not_to have_content(@app_group_b.name)
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User can see app group where the app group is registered on the group they are in' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role), user: user_b)

        login_as user_b

        visit root_path
        expect(page).to have_content(@app_group_a.name)
        expect(page).to have_content(@app_group_b.name)
      end
    end
  end

  describe 'Create applications group' do
    scenario 'User can create new application group' do
      set_check_user_groups({ 'groups': [] })
      login_as user_a
      prep_app_group = build(:app_group)

      visit root_path

      click_link 'New Application Group'
      within('#app_group_form') do
        fill_in 'app_group_name', with: prep_app_group.name
        select TPS_CONFIG.keys[0], from: 'app_group[capacity]'
      end

      click_button 'Submit'
      expect(page).to have_content(prep_app_group.name)
    end
  end

  describe 'Do Updrade/Manage Access and Create/Delete Barito App' do
    # before(:each) do
    #   @app_group_a = create(:app_group, created_by: user_a)
    #   @app_group_b = create(:app_group, created_by: user_b)

    #   [@app_group_a, @app_group_b].each { |app_group| create(:infrastructure, app_group: app_group) }
    # end

    context 'As Owner or As Superadmin' do
      scenario 'User can do those actions' do
        login_as user_a

        visit root_path
        click_link @app_group_a.name

        expect(page).to have_content('Create')
        expect(page).to have_content('Manage Access')
        expect(page).to have_content('Upgrade')
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with role member cannot do any actions' do
        # group = create(:group)
        # create(:app_group_permission, group: group, app_group: @app_group_a)
        # set_check_user_groups({ 'groups': [group.name]})
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role), user: user_b)

        login_as user_b
        visit root_path

        click_link @app_group_a.name

        expect(page).to have_current_path(app_group_path(@app_group_a))
        expect(page).not_to have_css('input[name="commit"][value="Create"]')
        expect(page).not_to have_content('Manage Access')
        expect(page).not_to have_content('Upgrade')
      end
    end
  end

  describe 'Managing Access', js: true do
    # before(:each) do
    #   @app_group_a = create(:app_group, created_by: user_a)
    #   @app_group_b = create(:app_group, created_by: user_b)

    #   [@app_group_a, @app_group_b].each { |app_group| create(:infrastructure, app_group: app_group) }
    # end

    context 'As Owner or Superadmin' do
      scenario 'User can add members to app group' do
        create(:app_group_role)
        login_as admin

        visit root_path
        click_link @app_group_a.name

        click_link 'Manage Access'
        set_select2_option(selector: '#assign_member_user_id', text: user_b.username, value: user_b.id)
        find('form#new_app_group_user input[value="Add"]').click

        expect(page).to have_content("#{user_b.username} - #{user_b.email}")
        expect(page).to have_css("a[href='#{app_group_user_path(user_id: user_b.id, app_group_id: @app_group_a.id)}']")

        # find("a[href='#{app_group_admin_path(AppGroupAdmin.first)}']").click
        # expect(page).not_to have_content("#{user_b.username} - #{user_b.email}")
      end

      # scenario 'User can assign group' do
      #   group = create(:group)
      #   login_as user_a

      #   visit root_path
      #   click_link @app_group_a.name

      #   click_link 'Manage Access'

      #   set_select2_option(selector: '#assign_group_id', text: group.name, value: group.id)
      #   find('form#new_app_group_permission input[value="Add"]').click
      #   expect(page).to have_content(group.name)

      #   find("a[href='#{app_group_permission_path(AppGroupPermission.first)}']").click
      #   expect(page).not_to have_content(group.name)
      # end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with role admin cannot manage access but can add/delete barito app' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :admin), user: user_b)
        # create(:app_group_admin, app_group: @app_group_a, user: user_b)

        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).not_to have_content('Manage Access')
        expect(page).to have_css("form#new_barito_app")
        

        # set_select2_option(selector: '#assign_admin_user_id', text: admin.username, value: admin.id)
        # find('form#new_app_group_admin input[value="Add"]').click
        # expect(page).to have_content("#{admin.username} - #{admin.email}")

        # find("a[href='#{app_group_admin_path(AppGroupAdmin.first)}']").click
        # expect(page).not_to have_content("#{admin.username} - #{admin.email}")
      end

      scenario 'User with role "owner" can do just like owner/superadmin' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :owner), user: user_b)

        # create(:app_group_admin, app_group: @app_group_a, user: user_b)
        # group = create(:group)
        login_as user_b

        visit root_path
        click_link @app_group_a.name

        expect(page).to have_content('Manage Access')
        expect(page).to have_css("form#new_barito_app")


        # set_select2_option(selector: '#assign_group_id', text: group.name, value: group.id)
        # find('form#new_app_group_permission input[value="Add"]').click
        # expect(page).to have_content(group.name)

        # find("a[href='#{app_group_permission_path(AppGroupPermission.first)}']").click
        # expect(page).not_to have_content(group.name)
      end
    end
  end
end
