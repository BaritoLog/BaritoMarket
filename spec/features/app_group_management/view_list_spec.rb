require 'rails_helper'

RSpec.feature 'Application Group Management', type: :feature do
  let(:user_a) { create(:user) }
  let(:user_b) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    @app_group_a = create(:app_group, created_by: user_a)
    @app_group_b = create(:app_group, created_by: user_b)

    [@app_group_a, @app_group_b].each { |app_group| create(:infrastructure, app_group: app_group) }
  end

  describe 'View applications group lists' do
    context 'As Owner/Superadmin' do
      scenario 'User can only see app group that they created' do
        login_as user_a

        visit root_path
        expect(page).to have_content(@app_group_a.name)
        expect(page).not_to have_content(@app_group_b.name)
      end
    end

    context 'As Authorized User based on Role' do
      scenario 'User can see app group where the app group is registered on the group they are in' do
        create(:app_group_user, app_group: @app_group_a, role: create(:app_group_role), user: user_b)

        login_as user_b

        visit root_path
        expect(page).to have_content(@app_group_a.name)
        expect(page).to have_content(@app_group_b.name)
      end
    end
  end
end
