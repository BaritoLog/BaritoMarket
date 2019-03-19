require 'rails_helper'

RSpec.feature 'Component Template Management', type: :feature do
  let(:user_a) { create(:user) }
  before(:each) do
    @component_template = create(:component_template)
  end

  describe 'Component template' do
    context 'Edit component template' do
      scenario 'User can edit component template' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        prep_component_template = build(:component_template)

        visit component_template_path(@component_template)

        click_link 'Edit'
        within('#edit_component_template') do
          fill_in 'component_template[env]', with: prep_component_template.env
          fill_in 'component_template[name]', with: prep_component_template.name
        end

        click_button 'Submit'
        expect(page).to have_content(prep_component_template.env)
        expect(page).to have_content(prep_component_template.name)
      end
    end
  end
end
