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

  describe 'View applications group lists' do
    context 'As Superadmin' do
      scenario 'User can only see app group that they created' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        login_as user_a

        visit root_path
        expect(page).to have_content(@app_group_a.name)
        expect(page).to have_content(@app_group_b.name)
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User can see app group where the app group is registered on the group they are in' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role), user: user_b)

        login_as user_b

        visit root_path
        expect(page).to have_content(@app_group_a.name)
        expect(page).not_to have_content(@app_group_b.name)
      end
    end

    context 'One of app group is bookmarked' do
      before :each do
        [@app_group_a, @app_group_b].each { |app_group| create(:app_group_user, app_group: app_group, user: user_a) }
        create(:app_group_bookmark, app_group: @app_group_a, user: user_a)
      end

      scenario 'List app groups' do
        login_as user_a
        visit root_path
        expect(@app_group_a.name).to appear_before(@app_group_b.name)
      end
    end
  end
end
