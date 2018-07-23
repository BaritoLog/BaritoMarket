require 'rails_helper'

RSpec.feature 'Group Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) { set_check_user_groups({ 'groups' => [] }) }

  describe 'View groups list' do
    context 'As Authorized User based on Group from Gate' do
      scenario 'User that registered to some groups in Gate and exists in BaritoMarket can see list of groups' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        group = create(:group, name: 'barito-superadmin')

        login_as user
        visit groups_path

        expect(page).to have_current_path(groups_path)
        expect(page).to have_content(group.name)
      end

      scenario 'User that not registered to some groups in Gate and/or exists in BaritoMarket cannot see list of groups' do
        login_as user
        visit groups_path

        expect(page).to have_current_path(root_path)
      end
    end
  end
end
