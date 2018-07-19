require 'rails_helper'

RSpec.feature 'Group Management', type: :feature do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  before(:each) { set_check_user_groups({ 'groups' => [] }) }

  describe 'Delete group' do
    context 'As Superadmin' do
      scenario 'User can delete any group' do
        group = create(:group)

        login_as admin
        visit groups_path

        expect(page).to have_content(group.name)
        expect(page).to have_content('Delete')

        click_link 'Delete'
        expect(page).not_to have_content(group.name)
        expect(page).not_to have_content('Delete')
      end
    end

    context 'As Authorized User based on Group from Gate' do
      scenario 'User that registered to some groups in Gate and exists in BaritoMarket can delete group' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        group = create(:group, name: 'barito-superadmin')

        login_as user
        visit groups_path

        expect(page).to have_content(group.name)
        expect(page).to have_content('Delete')

        click_link 'Delete'
        expect(page).not_to have_content(group.name)
        expect(page).not_to have_content('Delete')
      end

      scenario 'User that registered to some groups in Gate and exists in BaritoMarket cannot delete group' do
        login_as user
        visit new_group_path

        expect(page).to have_current_path(root_path)
      end
    end
  end
end
