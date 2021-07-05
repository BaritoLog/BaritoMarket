require 'rails_helper'

RSpec.feature 'Barito App Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:admin) { create(:user) }
  let(:helm_cluster_template) { create(:helm_cluster_template) }

  describe 'Create new barito app' do
    before(:each) do
      set_check_user_groups({ 'groups' => [] })
      @app_group = create(:app_group)
      create(:helm_infrastructure, app_group: @app_group, helm_cluster_template: helm_cluster_template)
    end

    context 'As Superadmin' do
      scenario 'User can create/add barito app' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
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
      scenario 'User with "owner" or "admin" role can create barito app' do
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role, :owner), user: user_b)

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

      scenario 'User with "member" role cannot create barito app' do
        create(:app_group_user, app_group: @app_group, role: create(:app_group_role), user: user_b)

        login_as user_b

        build(:barito_app)
        visit app_group_path(@app_group)

        expect(page).not_to have_css('form#new_barito_app input[type="submit"]')
      end
    end
  end
end
