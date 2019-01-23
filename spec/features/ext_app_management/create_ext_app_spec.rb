require 'rails_helper'

RSpec.feature 'Ext. App Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) { set_check_user_groups({ 'groups' => [] }) }

  describe 'Create new ext. app' do
    context 'As Authorized User based on Group from Gate' do
      scenario 'User that registered to some groups in Gate and exists in BaritoMarket can create new ext. app' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        ext_app_attr = build(:ext_app)

        login_as user
        visit new_ext_app_path

        within('#new_ext_app') do
          fill_in 'ext_app[name]', with: ext_app_attr.name
          fill_in 'ext_app[description]', with: ext_app_attr.description
        end

        click_button 'Submit'

        expect(page).to have_current_path(ext_app_path(ExtApp.last.id))
        expect(page).to have_content(ext_app_attr.name)
      end

      scenario 'User that not registered to some groups in Gate and/or exists in BaritoMarket cannot create new ext. app' do
        login_as user
        visit new_ext_app_path

        expect(page).to have_current_path(root_path)
      end
    end
  end
end
