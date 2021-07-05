require 'rails_helper'

RSpec.feature 'Barito App Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:admin) { create(:user) }
  let(:helm_cluster_template) { create(:helm_cluster_template) }

  describe 'Toggle Status App' do
    before(:each) do
      set_check_user_groups({ 'groups' => [] })

      @app_group = create(:app_group)
      create(:helm_infrastructure, app_group: @app_group, helm_cluster_template: helm_cluster_template)
      @barito_app = create(:barito_app, app_group: @app_group)
    end

    context 'As Superadmin' do
      scenario 'User is allowed to toggle status of the App', js: true do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as admin
        create(:group, name: 'barito-superadmin')

        visit root_path
        click_link @app_group.name
        expect(page).to have_content @barito_app.name
        expect(@barito_app.status).to eq BaritoApp.statuses[:inactive]
        expect(page).to have_selector("#toggle_app_status_#{@barito_app.id}", visible: false)

        page.execute_script("$('#toggle_app_status_#{@barito_app.id}').prop('checked', true).change();")
        expect(@barito_app.reload.status).to eq BaritoApp.statuses[:active]
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User with "owner" and "admin" role is allowed to change status app', js: true do
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role, :admin), user: user_b)

        login_as user_b

        visit root_path
        click_link @app_group.name
        expect(page).to have_content @barito_app.name
        expect(@barito_app.status).to eq BaritoApp.statuses[:inactive]
        expect(page).to have_selector("#toggle_app_status_#{@barito_app.id}", visible: false)

        page.execute_script("$('#toggle_app_status_#{@barito_app.id}').prop('checked', true).change();")
        expect(@barito_app.reload.status).to eq BaritoApp.statuses[:active]
      end

      scenario 'User with "member" role cannot change status app' do
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role), user: user_a)

        login_as user_a

        visit root_path
        click_link @app_group.name
        expect(page).to have_content @barito_app.name
        expect(page).not_to have_css "input#toggle_app_status_#{@barito_app.id}"
      end
    end
  end
end
