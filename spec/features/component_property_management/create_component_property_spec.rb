require 'rails_helper'

RSpec.feature 'Component property Management', type: :feature do
  let(:user_a) { create(:user) }
  before(:each) do
    @component_property = create(:component_property)
  end

  describe 'Component property' do
    context 'Create component property' do
      scenario 'User can create new Component property' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        prep_component_property = build(:component_property)

        visit component_properties_path

        click_link 'New Component Property'
        within('#new_component_property') do
          fill_in 'component_property_name', with: prep_component_property.name
          fill_in 'component_property_component_attributes', with: prep_component_property.component_attributes.to_json
        end

        click_button 'Submit'
        expect(page).to have_content(prep_component_property.name)
      end
    end
  end
end
