require 'rails_helper'

RSpec.feature 'List Groups', type: :feature do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  before(:each) do
    set_check_user_groups({ groups: [] })
  end

  context 'As Superadmin' do
    scenario 'User can see list of registered groups' do
      login_as admin
      groups = create_list(:group, 5)
      visit groups_path
      groups.each do |group|
        expect(page).to have_content(group.name)
      end
    end
  end

  context 'As Plain User' do
    scenario 'User not allowed to access this page' do
      login_as user
      visit groups_path

      expect(page).to have_current_path(root_path)
    end
  end
end
