require 'rails_helper'

RSpec.feature 'Component template Management', type: :feature do
  let(:user_a) { create(:user) }

  describe 'Component template' do
    context 'Create component template' do
      scenario 'User can create new Component template' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        prep_component_template = build(:component_template)

        visit component_templates_path

        click_link 'New Component Template'
        within('#new_component_template') do
          fill_in 'component_template[name]', with: "test"
          fill_in 'component_template[image_alias]', with: "image-test"
          fill_in 'component_template[component_attributes]', with: prep_component_template.component_attributes.to_json
        end

        click_button 'Submit'
        expect(page).to have_content("test")

        click_link 'test'
        expect(page).to have_content("image-test")
      end
    end
  end
end
