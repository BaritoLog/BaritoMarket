require 'rails_helper'

RSpec.feature 'Ext. App Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) do 
    set_check_user_groups({ 'groups' => [] })
  end

  describe 'View ext. apps list' do
    context 'As Authorized User based on Group from Gate' do
      scenario 'User that registered to some groups in Gate and exists in BaritoMarket can see list of ext. apps' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        ext_app = create(:ext_app, name: 'Ext App 1')

        login_as user
        visit ext_apps_path

        expect(page).to have_current_path(ext_apps_path)
        expect(page).to have_content(ext_app.name)
      end

      scenario 'User that not registered to some groups in Gate and/or exists in BaritoMarket cannot see list of ext. apps' do
        login_as user
        visit ext_apps_path

        expect(page).to have_current_path(root_path)
      end
    end
  end
end
