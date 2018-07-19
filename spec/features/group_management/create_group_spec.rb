require 'rails_helper'

RSpec.feature 'Group Management', type: :feature do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  before(:each) { set_check_user_groups({ 'groups' => [] }) }

  describe 'Create new group' do
    context 'As Superadmin' do
      scenario 'User can create new group' do
        prep_group = build(:group)

        login_as admin
        visit new_group_path

        within('#new_group') do
          fill_in 'group_name', with: prep_group.name
        end

        click_button 'Submit'

        expect(page).to have_current_path(groups_path)
        expect(page).to have_content(prep_group.name)
      end
    end

    context 'As Authorized User based on Group from Gate' do
      scenario 'User that registered to some groups in Gate and exists in BaritoMarket can create new group' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        group = create(:group, name: 'barito-superadmin')
        prep_group = build(:group)

        login_as user
        visit new_group_path

        within('#new_group') do
          fill_in 'group_name', with: prep_group.name
        end

        click_button 'Submit'

        expect(page).to have_current_path(groups_path)
        expect(page).to have_content(prep_group.name)
      end

      scenario 'User that not registered to some groups in Gate and/or exists in BaritoMarket cannot create new group' do
        login_as user
        visit new_group_path

        expect(page).to have_current_path(root_path)
      end
    end
  end
end
