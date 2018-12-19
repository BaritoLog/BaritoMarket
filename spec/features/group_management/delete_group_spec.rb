require 'rails_helper'

RSpec.feature 'Group Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) { set_check_user_groups({ 'groups' => [] }) }

  describe 'Delete group' do
    context 'As Authorized User based on Group from Gate' do
      scenario 'User that registered to some groups in Gate and exists in BaritoMarket can delete group' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        group = create(:group, name: 'barito-test')

        login_as user
        visit groups_path

        expect(page).to have_content(group.name)
        expect(page).to have_content('Delete')

        find("a[data-method='delete'][href='/groups/#{group.id}']").click
        expect(page).not_to have_content(group.name)
      end

      scenario 'User that registered to some groups in Gate and exists in BaritoMarket cannot delete group' do
        login_as user
        visit new_group_path

        expect(page).to have_current_path(root_path)
      end
    end
  end
end
