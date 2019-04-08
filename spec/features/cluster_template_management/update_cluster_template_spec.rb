require 'rails_helper'

RSpec.feature 'Cluster Template Management', type: :feature do
  let(:user_a) { create(:user) }
  before(:each) do
    @cluster_template = create(:cluster_template)
  end

  describe 'Cluster template' do
    context 'Edit cluster template' do
      scenario 'User can edit cluster template' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a
        prep_cluster_template = build(:cluster_template)

        visit cluster_template_path(@cluster_template)

        click_link 'Edit'
        within('#edit_cluster_template') do
          fill_in 'cluster_template[name]', with: prep_cluster_template.name
        end

        click_button 'Submit'
        expect(page).to have_content(prep_cluster_template.name)
      end
    end
  end
end
