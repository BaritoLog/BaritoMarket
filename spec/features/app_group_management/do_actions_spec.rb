require 'rails_helper'

RSpec.feature 'Application Group Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    @app_group_a = create(:app_group)
    @app_group_b = create(:app_group)

    [@app_group_a, @app_group_b].each { |app_group| create(:infrastructure, app_group: app_group) }
  end

  describe 'Do Updrade/Manage Access and Create/Delete Barito App' do
    context 'As Superadmin' do
      scenario 'User is allowed to do those actions' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        create(:group, name: 'barito-superadmin')

        visit root_path
        click_link @app_group_a.name

        expect(page).to have_content('Create')
        expect(page).to have_content('Manage Access')
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with role "owner" can do those actions' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :owner), user: user_b)

        login_as user_b
        visit root_path

        click_link @app_group_a.name

        expect(page).to have_current_path(app_group_path(@app_group_a))
        expect(page).to have_css('input[name="commit"][value="Create"]')
        expect(page).to have_content('Manage Access')
      end

      scenario 'User with role "admin" can do those actions' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role, :admin), user: user_b)

        login_as user_b
        visit root_path

        click_link @app_group_a.name

        expect(page).to have_current_path(app_group_path(@app_group_a))
        expect(page).to have_css('input[name="commit"][value="Create"]')
        expect(page).not_to have_content('Manage Access')
      end

      scenario 'User with role "member" cannot do any actions' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role), user: user_b)

        login_as user_b
        visit root_path

        click_link @app_group_a.name

        expect(page).to have_current_path(app_group_path(@app_group_a))
        expect(page).not_to have_css('input[name="commit"][value="Create"]')
        expect(page).not_to have_content('Manage Access')
      end
    end
  end
end
