require 'rails_helper'

RSpec.feature 'Deployment template Management', type: :feature do
  let(:user_a) { create(:user) }

  describe 'Deployment template' do
    context 'Create deployment template' do
      scenario 'User can create new Deployment template' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        prep_deployment_template = build(:deployment_template)

        visit deployment_templates_path

        click_link 'New Deployment Template'
        within('#new_deployment_template') do
          fill_in 'deployment_template[name]', with: "test"
          fill_in 'deployment_template[source]', with: prep_deployment_template.source.to_json
          fill_in 'deployment_template[bootstrappers]', with: prep_deployment_template.bootstrappers.to_json
        end

        click_button 'Submit'
        expect(page).to have_content("test")

        click_link 'test'
        expect(page).to have_content('barito-registry')
      end
    end
  end
end
