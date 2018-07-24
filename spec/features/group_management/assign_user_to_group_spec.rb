require 'rails_helper'

RSpec.feature 'Group Management', type: :feature do
  let(:user) { create(:user) }
  let(:admin) { create(:user) }

  before(:each) { set_check_user_groups({ 'groups' => [] }) }

  describe 'Assign User to Group', js: true do
    context 'As Authorized User based on Group from Gate' do
      scenario 'User that registered to some groups in Gate and exists in BaritoMarket can assign user' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        group = create(:group, name: 'barito-superadmin')

        login_as admin
        visit group_path(group)

        expect(page).to have_content("Group - #{group.name}")
        set_select2_option(selector: '#assign_member_user_id', text: "#{user.username} - #{user.email}", value: user.id)

        click_button 'Add'
        expect(page).to have_content("#{user.username} - #{user.email}")
      end

      scenario 'User that not registered to some groups in Gate and exists in BaritoMarket cannot assign user' do
        login_as user
        visit new_group_path

        expect(page).to have_current_path(root_path)
      end
    end
  end
end
