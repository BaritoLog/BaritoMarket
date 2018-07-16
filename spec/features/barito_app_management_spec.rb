require 'rails_helper'

RSpec.feature 'Barito App Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe 'View registered barito apps list' do
    before(:each) do
      @app_group = create(:app_group, created_by: user_a)
      create(:infrastructure, app_group: @app_group)
      @barito_app = create(:barito_app, app_group: @app_group)
    end

    context 'As Owner/Creator' do
      scenario 'User can see barito app lists in application group page' do
        login_as user_a
        visit root_path

        click_link @app_group.name

        expect(page).to have_content(@barito_app.name)
      end
    end

    context 'As Superadmin' do
      scenario 'User can see all registered barito app in application group page' do
        login_as admin
        visit root_path

        click_link @app_group.name

        expect(page).to have_content(@barito_app.name)
      end
    end

    context 'As Authorized User through group' do
      scenario 'User can only see barito app where the app group is registered on the group they are in' do
        group = create(:group)
        create(:app_group_permission, group: group, app_group: @app_group)
        set_check_user_groups({ 'groups': [group.name] })

        login_as user_b

        visit root_path
        click_link @app_group.name

        expect(page).to have_content(@barito_app.name)
      end
    end
  end

  describe 'Create new barito app' do
    before(:each) do
      @app_group_a = create(:app_group, created_by: user_a)
      create(:infrastructure, app_group: @app_group_a)
    end

    context 'As Owner/ As Superadmin' do
      scenario 'User can create/add barito app' do
        login_as admin

        barito_app = build(:barito_app)
        visit app_group_path(@app_group_a)

        within('#new_barito_app') do
          fill_in 'barito_app_topic_name', with: barito_app.name
          fill_in 'barito_app_name', with: barito_app.name
          fill_in 'barito_app_max_tps', with: 50
        end

        click_button 'Create'

        expect(page).to have_content(barito_app.name)
      end
    end

    context 'As Authorized Admin through Group' do
      scenario 'User can create/add barito app' do
        create(:app_group_admin, user: user_b, app_group: @app_group_a)

        login_as user_b

        barito_app = build(:barito_app)
        visit app_group_path(@app_group_a)

        within('#new_barito_app') do
          fill_in 'barito_app_topic_name', with: barito_app.name
          fill_in 'barito_app_name', with: barito_app.name
          fill_in 'barito_app_max_tps', with: 50
        end

        click_button 'Create'

        expect(page).to have_content(barito_app.name)
      end
    end

    context 'As Plain User' do
      scenario 'User cannot create/add barito app' do
        login_as user_b

        visit app_group_path(@app_group_a)
        expect(page).to have_current_path(root_path)
        expect(page).to have_content('You are not authorized to perform this action')
      end
    end
  end

  describe 'Delete barito app' do
    before(:each) do
      @app_group_a = create(:app_group, created_by: user_a)
      create(:infrastructure, app_group: @app_group_a)
      @barito_app = create(:barito_app, app_group: @app_group_a)
    end

    context 'As Owner/As Superadmin' do
      scenario 'User can delete existing barito app' do
        login_as admin

        visit app_group_path(@app_group_a)

        expect(page).to have_content(@barito_app.name)

        click_link 'Delete'
        expect(page).not_to have_content(@barito_app.name)
      end
    end

    context 'As Authorized Admin through Group' do
      scenario 'User can delete existing barito app' do
        create(:app_group_admin, app_group: @app_group_a, user: user_b)

        login_as user_b

        visit app_group_path(@app_group_a)

        expect(page).to have_content(@barito_app.name)

        click_link 'Delete'
        expect(page).not_to have_content(@barito_app.name)
      end
    end

    context 'As Plain User' do
      scenario 'User cannot delete existing barito app' do
        login_as user_b

        visit app_group_path(@app_group_a)
        expect(page).to have_current_path(root_path)
        expect(page).to have_content('You are not authorized to perform this action')
      end
    end
  end
end
