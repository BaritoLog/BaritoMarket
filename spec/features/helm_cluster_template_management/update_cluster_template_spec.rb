require 'rails_helper'

RSpec.feature 'Helm Cluster Template Management', type: :feature do
  let(:user_a) { create(:user) }
  before(:each) do
    @helm_cluster_template = create(:helm_cluster_template)
  end

  describe 'Helm Cluster template' do
    context 'Edit helm cluster template' do
      scenario 'User can edit helm cluster template' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        prep_helm_cluster_template = build(:helm_cluster_template)

        visit helm_cluster_template_path(@helm_cluster_template)

        click_link 'Edit'
        within('#edit_helm_cluster_template') do
          fill_in 'helm_cluster_template[name]', with: prep_helm_cluster_template.name
        end

        click_button 'Submit'
        expect(page).to have_content(prep_helm_cluster_template.name)
      end
    end
  end
end
