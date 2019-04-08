require 'rails_helper'

RSpec.feature 'Component Template Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })
    @component_template = create(:component_template)
  end

  describe 'View component template details' do
    context 'As Superadmin' do
      scenario 'User allowed to see component template details' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        login_as user

        visit component_template_path(@component_template.id)
        expect(page).to have_content(@component_template.name)
      end
    end
  end
end
