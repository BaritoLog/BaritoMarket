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

    context 'As Owner/ As Superadmin' do
      scenario 'User can see barito app lists in application group page' do
        login_as user_a
        visit root_path

        click_link @app_group.name

        expect(page).to have_content(@barito_app.name)
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User registered as member in app group can see the barito app list' do
        # group = create(:group)
        # create(:app_group_permission, group: group, app_group: @app_group)
        # set_check_user_groups({ 'groups': [group.name] })

        create(:app_group_user, app_group: @app_group, role: create(:app_group_role), user: user_b)
        login_as user_b

        visit root_path
        click_link @app_group.name

        expect(page).to have_content(@barito_app.name)
      end
    end
  end

  describe 'Create new barito app' do
    before(:each) do
      @app_group = create(:app_group, created_by: user_a)
      create(:infrastructure, app_group: @app_group)
    end

    context 'As Owner/ As Superadmin' do
      scenario 'User can create/add barito app' do
        login_as admin

        barito_app = build(:barito_app)
        visit app_group_path(@app_group)

        within('#new_barito_app') do
          fill_in 'barito_app_topic_name', with: barito_app.name
          fill_in 'barito_app_name', with: barito_app.name
          fill_in 'barito_app_max_tps', with: 50
        end

        click_button 'Create'
        expect(page).to have_content(barito_app.name)
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with admin/owner role can create barito app' do
        # create(:app_group_admin, user: user_b, app_group: @app_group)
        
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role, :admin), user: user_b)

        login_as user_b

        barito_app = build(:barito_app)
        visit app_group_path(@app_group)

        within('#new_barito_app') do
          fill_in 'barito_app_topic_name', with: barito_app.name
          fill_in 'barito_app_name', with: barito_app.name
          fill_in 'barito_app_max_tps', with: 50
        end

        click_button 'Create'

        expect(page).to have_content(barito_app.name)
      end

      scenario 'User with member role cannot create barito app' do
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role), user: user_b)

        login_as user_b

        barito_app = build(:barito_app)
        visit app_group_path(@app_group)

        expect(page).not_to have_css('form#new_barito_app input[type="submit"]')
      end
    end

    # context 'As Plain User' do
    #   scenario 'User cannot create/add barito app' do
    #     login_as user_b

    #     visit app_group_path(@app_group)
    #     expect(page).to have_current_path(root_path)
    #     expect(page).to have_content('You are not authorized to perform this action')
    #   end
    # end
  end

  describe 'Delete barito app' do
    before(:each) do
      @app_group = create(:app_group, created_by: user_a)
      create(:infrastructure, app_group: @app_group)
      @barito_app = create(:barito_app, app_group: @app_group)
    end

    context 'As Owner/As Superadmin' do
      scenario 'User can delete existing barito app' do
        login_as admin

        visit app_group_path(@app_group)

        expect(page).to have_content(@barito_app.name)

        click_link 'Delete'
        expect(page).not_to have_content(@barito_app.name)
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with owner/admin role can delete existing barito app' do
        # create(:app_group_admin, app_group: @app_group, user: user_b)
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role, :admin), user: user_b)

        login_as user_b

        visit app_group_path(@app_group)

        expect(page).to have_content(@barito_app.name)

        click_link 'Delete'
        expect(page).not_to have_content(@barito_app.name)
      end

      scenario 'User with member role cannot delete existing barito app' do
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role), user: user_b)

        login_as user_b
        visit app_group_path(@app_group)

        expect(page).to have_content(@barito_app.name)
        expect(page).not_to have_css("a[href='#{app_path(@barito_app)}'][data-method='delete']")
      end
    end

    # context 'As Plain User' do
    #   scenario 'User cannot delete existing barito app' do
    #     login_as user_b

    #     visit app_group_path(@app_group)
    #     expect(page).to have_current_path(root_path)
    #     expect(page).to have_content('You are not authorized to perform this action')
    #   end
    # end
  end
end
