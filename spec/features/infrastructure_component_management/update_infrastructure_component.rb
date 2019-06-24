require 'rails_helper'

RSpec.feature 'Infrastructure Component Management - ', type: :feature do
  let(:user_a) { create(:user) }
  before(:each) do
    @infrastructure = create(:infrastructure)
  end

  describe 'Infrastructure Component - ' do
    context 'Update infrastructure component - ' do
      scenario 'User can edit infrastructure component' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        prep_infrastructure_component = build(:infrastructure_component)

        visit infrastructure_path(@infrastructure)
        expect(page).to have_content(@infrastructure.cluster_name)

        within('#edit_infrastructure_component') do
          fill_in 'infrastructure_component[image_alias]', with: prep_infrastructure_component.image_alias
          fill_in 'infrastructure_component[bootstrap_attributes]', with: prep_infrastructure_component.bootstrap_attributes.to_json
        end

        click_button 'Submit'
        expect(page).to have_content(prep_infrastructure_component.bootstrap_attributes)
        expect(page).to have_content(prep_infrastructure_component.image_alias)
      end
    end
  end
end
