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
          fill_in 'infrastructure_component[source]', with: prep_infrastructure_component.source.to_json
          fill_in 'infrastructure_component[bootstrappers]', with: prep_infrastructure_component.bootstrappers.to_json
        end

        click_button 'Submit'
        expect(page).to have_content(prep_infrastructure_component.bootstrappers)
        expect(page).to have_content(prep_infrastructure_component.source)
      end
    end
  end
end
