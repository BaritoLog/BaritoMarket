require 'rails_helper'

RSpec.feature 'Component Template Management', type: :feature do
  let(:user_a) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    @deployment_template = create(:deployment_template)
  end

  describe 'View component template lists' do
    context 'As Superadmin' do
      scenario 'User can see list of component properties' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        login_as user_a

        visit deployment_templates_path
        expect(page).to have_content(@deployment_template.name)
      end
    end
  end
end
