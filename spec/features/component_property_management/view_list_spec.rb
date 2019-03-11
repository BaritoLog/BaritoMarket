require 'rails_helper'

RSpec.feature 'Component Property Management', type: :feature do
  let(:user_a) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    @component_property = create(:component_property)
  end

  describe 'View component property lists' do
    context 'As Superadmin' do
      scenario 'User can see list of component properties' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        login_as user_a

        visit component_properties_path
        expect(page).to have_content(@component_property.name)
      end
    end
  end
end
