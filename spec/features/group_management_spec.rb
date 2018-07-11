require 'rails_helper'

RSpec.feature 'Group Management', type: :feature do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  before(:each) { set_check_user_groups({ 'groups' => [] }) }

  describe 'View groups list' do
    context 'As Superadmin' do
      scenario 'User can see list of registered groups' do
        puts '*' * 100
        puts Capybara.javascript_driver
        login_as admin
        groups = create_list(:group, 5)
        visit groups_path
        groups.each do |group|
          expect(page).to have_content(group.name)
        end
      end
    end

    context 'As Plain User' do
      scenario 'User cannot see group lists' do
        login_as user
        visit groups_path

        expect(page).to have_current_path(root_path)
      end
    end
  end

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

    context 'As Plain User' do
      scenario 'User cannot create group' do
        login_as user
        visit new_group_path

        expect(page).to have_current_path(root_path)
      end
    end
  end

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

    context 'As Plain User' do
      scenario 'User cannot delete any group' do
        login_as user
        visit new_group_path

        expect(page).to have_current_path(root_path)
      end
    end
  end

  describe 'Assign User to Group' do
    context 'As Superadmin' do
      scenario 'User can assign user to group' do
        group = create(:group)

        binding.pry
        login_as admin
        visit group_path(group)

        expect(page).to have_content("Group - #{group.name}")
        skip 'Still have problem with javascript driver'
        # set_select2_option(selector: '#assign_member_user_id', text: group.name, value: group.id)
      end
    end

    context 'As Plain User' do
      scenario 'User cannot delete any group' do
        login_as user
        visit new_group_path

        expect(page).to have_current_path(root_path)
      end
    end
  end
end
