require 'rails_helper'

RSpec.feature 'View Applications', type: :feature do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }

  before(:each) do
    login_as user
    set_check_user_groups({groups: []})
  end

  context 'As Creator' do
    scenario 'Can view registered applications' do
      app_group = create(:app_group, created_by: user)
      infrastructure = create(:infrastructure, app_group: app_group)
      barito_app = create(:barito_app, app_group: app_group)
      login_as(user)

      visit root_path
      expect(page).to have_content(app_group.name)

      click_link app_group.name
      expect(page).to have_current_path(app_group_path(app_group))
      expect(page).to have_content(barito_app.name).and have_content(barito_app.topic_name)
    end
  end

  context 'As Unauthorized User' do
    scenario "Can only see their own applications" do
      logout
      app_group_a = create(:app_group, created_by: user)
      app_group_b = create(:app_group, created_by: user2)

      [app_group_a, app_group_b].each do |app_group|
        create(:infrastructure, app_group: app_group)
      end

      login_as(user2)
      visit root_path

      expect(page).to have_content(app_group_b.name)
      expect(page).not_to have_content(app_group_a.name)
    end
  end

  context 'As Authorized User' do
    scenario 'User can see applications in their registered group' do
      logout
      app_group = create(:app_group, created_by: user)
      create(:infrastructure, app_group: app_group)
      group = create(:group)
      create(:app_group_permission, group: group, app_group: app_group)

      set_check_user_groups({'groups' => [group.name]})
      login_as(user2)
      visit root_path

      expect(page).to have_content(app_group.name)
    end
  end
end
