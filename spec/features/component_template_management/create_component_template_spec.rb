require 'rails_helper'

RSpec.feature 'Component Template Management', type: :feature do
  let(:user_a) { create(:user) }
  before(:each) do
    @component_template = create(:component_template)
  end

  describe 'Component template' do
    context 'Create component template' do
      scenario 'User can create new Component Template' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        prep_component_template = build(:component_template)

        visit component_templates_path

        click_link 'New Component Template'
        within('#new_component_template') do
          fill_in 'component_template_env', with: prep_component_template.env
          fill_in 'component_template_name', with: prep_component_template.name
          fill_in 'component_template_max_tps', with: prep_component_template.max_tps
          fill_in 'component_template_instances', with: prep_component_template.instances
          fill_in 'component_template_kafka_options', with: prep_component_template.kafka_options
        end

        click_button 'Submit'
        expect(page).to have_content(prep_component_template.name)
      end
    end
  end
end
