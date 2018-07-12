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
end
