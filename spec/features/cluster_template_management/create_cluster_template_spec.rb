require 'rails_helper'

RSpec.feature 'Cluster Template Management', type: :feature do
  let(:user_a) { create(:user) }
  before(:each) do
    @cluster_template = create(:cluster_template)
  end

  describe 'Cluster template' do
    context 'Create cluster template' do
      scenario 'User can create new Cluster Template' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        prep_cluster_template = build(:cluster_template)

        visit cluster_templates_path

        click_link 'New Cluster Template'
        within('#new_cluster_template') do
          fill_in 'cluster_template[name]', with: prep_cluster_template.name
          fill_in 'cluster_template[instances]', with: prep_cluster_template.instances.to_json
          fill_in 'cluster_template[kafka_options]', with: prep_cluster_template.kafka_options.to_json
        end

        click_button 'Submit'
        expect(page).to have_content(prep_cluster_template.name)
      end
    end
  end
end
