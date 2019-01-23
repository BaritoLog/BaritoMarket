require 'rails_helper'

RSpec.feature 'Ext. App Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) { set_check_user_groups({ 'groups' => [] }) }

  describe 'Delete ext_app' do
    context 'As Authorized User based on Group from Gate' do
      scenario 'User that registered to some groups in Gate and exists in BaritoMarket can delete ext. app' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        ext_app = create(:ext_app, name: 'barito-test')

        login_as user
        visit ext_apps_path

        expect(page).to have_content(ext_app.name)
        expect(page).to have_content('Delete')

        find("a[data-method='delete'][href='/ext_apps/#{ext_app.id}']").click
        expect(page).not_to have_content(ext_app.name)
      end
    end
  end
end
