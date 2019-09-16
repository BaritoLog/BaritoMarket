require 'rails_helper'

RSpec.feature 'Infrastructure Component Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })
    @infrastructure = create(:infrastructure)
    @infrastructure_components = []
    3.times.each do
      @infrastructure_components << create(:infrastructure_component, infrastructure: @infrastructure)
    end
  end

  describe 'View infrastructure component list' do
    context 'As Superadmin' do
      scenario 'User allowed to see infrastructure component list' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        login_as user

        visit infrastructure_components_path
        @infrastructure_components.each do |component|
          expect(page).to have_content(component.hostname)
        end
      end
    end

    context 'As other users' do
      scenario 'User is not allowed to see infrastructure details' do
        login_as user

        visit infrastructure_components_path

        expect(page).to have_current_path(root_path)
        expect(page).to have_content('You are not authorized to perform this action')
      end
    end
  end
end
