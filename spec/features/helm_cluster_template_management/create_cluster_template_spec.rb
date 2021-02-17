require 'rails_helper'

RSpec.feature 'Helm Cluster Template Management', type: :feature do
  let(:user_a) { create(:user) }

  describe 'Helm Cluster template' do
    context 'Create helm cluster template' do
      scenario 'User can create new Helm Cluster Template' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        prep_helm_cluster_template = build(:helm_cluster_template)

        visit helm_cluster_templates_path

        click_link 'New Helm Cluster Templates'
        within('#new_helm_cluster_template') do
          fill_in 'helm_cluster_template[name]', with: prep_helm_cluster_template.name
          fill_in 'helm_cluster_template[values]', with: prep_helm_cluster_template.values.to_json
          fill_in 'helm_cluster_template[max_tps]', with: prep_helm_cluster_template.max_tps
        end

        click_button 'Submit'
        expect(page).to have_content(prep_helm_cluster_template.name)
      end
    end
  end
end
