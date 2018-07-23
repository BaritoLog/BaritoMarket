require 'rails_helper'

RSpec.feature 'Barito App Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:admin) { create(:user) }

  describe 'Delete barito app' do
    before(:each) do
      set_check_user_groups({ 'groups' => [] })

      @app_group = create(:app_group, created_by: user_a)
      create(:infrastructure, app_group: @app_group)
      @barito_app = create(:barito_app, app_group: @app_group)
    end

    context 'As Owner/As Superadmin' do
      scenario 'User can delete existing barito app' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        login_as admin

        visit app_group_path(@app_group)
        expect(page).to have_content(@barito_app.name)

        click_link 'Delete'
        expect(page).not_to have_content(@barito_app.name)
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with owner/admin role can delete existing barito app' do
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
  end
end
