require 'rails_helper'

RSpec.feature 'Component property Management', type: :feature do
  let(:user_a) { create(:user) }
  before(:each) do
    @component_property = create(:component_property)
  end

  describe 'Component property' do
    context 'Update component property' do
      scenario 'User can edit component property' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        prep_component_property = build(:component_property)

        visit component_property_path(@component_property)

        click_link 'Edit'
        within('#edit_component_property') do
          fill_in 'component_property[name]', with: prep_component_property.name
        end

        click_button 'Submit'
        expect(page).to have_content(prep_component_property.name)
      end
    end
  end
end
