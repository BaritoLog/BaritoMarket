require 'rails_helper'

RSpec.feature 'Component template Management', type: :feature do
  let(:user_a) { create(:user) }
  before(:each) do
    @deployment_template = create(:deployment_template)
  end

  describe 'Component template' do
    context 'Update component template' do
      scenario 'User can edit component template' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        prep_deployment_template = build(:deployment_template)

        visit deployment_template_path(@deployment_template)

        click_link 'Edit'
        within('#edit_deployment_template') do
          fill_in 'deployment_template[name]', with: prep_deployment_template.name
          fill_in 'deployment_template[source]', with: prep_deployment_template.source.to_json
          fill_in 'deployment_template[bootstrappers]', with: prep_deployment_template.bootstrappers.to_json
        end

        click_button 'Submit'
        expect(page).to have_content(prep_deployment_template.name)
        expect(page).to have_content('barito-registry')
      end
    end
  end
end
