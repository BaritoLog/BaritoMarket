require 'rails_helper'

RSpec.feature 'Component Property Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })
    @component_property = create(:component_property)
  end

  describe 'View component property details' do
    context 'As Superadmin' do
      scenario 'User allowed to see component property details' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        login_as user

        visit component_property_path(@component_property.id)
        expect(page).to have_content(@component_property.name)
      end
    end
  end
end
