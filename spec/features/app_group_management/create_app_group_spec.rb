require 'rails_helper'

RSpec.feature 'Application Group Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }
  let(:admin) { create(:user, :admin) }

  before(:each) do
    @app_group_a = create(:app_group, created_by: user_a)
    @app_group_b = create(:app_group, created_by: user_b)

    [@app_group_a, @app_group_b].each { |app_group| create(:infrastructure, app_group: app_group) }
  end

  describe 'Create applications group' do
    scenario 'User can create new application group' do
      set_check_user_groups({ 'groups': [] })
      login_as user_a
      prep_app_group = build(:app_group)

      visit root_path

      click_link 'New Application Group'
      within('#app_group_form') do
        fill_in 'app_group_name', with: prep_app_group.name
        select TPS_CONFIG.keys[0], from: 'app_group[capacity]'
      end

      click_button 'Submit'
      expect(page).to have_content(prep_app_group.name)
    end
  end
end
