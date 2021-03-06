require 'rails_helper'

RSpec.feature 'Barito App Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:user_b) { create(:user) }
  let(:helm_cluster_template) { create(:helm_cluster_template) }


  describe 'View registered barito apps list' do
    before(:each) do
      set_check_user_groups({ 'groups' => [] })

      @app_group = create(:app_group)
      create(:helm_infrastructure, app_group: @app_group, helm_cluster_template: helm_cluster_template)
      @barito_app = create(:barito_app, app_group: @app_group)
    end

    context 'As Superadmin' do
      scenario 'User can see barito app lists in application group page' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        create(:group, name: 'barito-superadmin')
        visit root_path

        click_link @app_group.name

        expect(page).to have_content(@barito_app.name)
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with "owner" or "admin" or "member" role can see the barito app list' do
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role, :admin), user: user_b)
        login_as user_b

        visit root_path
        click_link @app_group.name

        expect(page).to have_content(@barito_app.name)

        logout

        create(:app_group_user, app_group: @app_group, role: create(:app_group_role), user: user_a)
        login_as user_a

        visit root_path
        click_link @app_group.name

        expect(page).to have_content(@barito_app.name)
      end
    end
  end
end
