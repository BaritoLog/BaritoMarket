require 'rails_helper'

RSpec.feature 'Component Template Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })
    @deployment_template = create(:deployment_template)
  end

  describe 'View component template details' do
    context 'As Superadmin' do
      scenario 'User allowed to see component template details' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        login_as user

        visit deployment_template_path(@deployment_template.id)
        expect(page).to have_content(@deployment_template.name)
      end
    end
  end
end
