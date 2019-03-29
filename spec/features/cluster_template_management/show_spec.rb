require 'rails_helper'

RSpec.feature 'Cluster Template Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })
    @cluster_template = create(:cluster_template)
  end

  describe 'View cluster template details' do
    context 'As Superadmin' do
      scenario 'User allowed to see cluster template details' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        login_as user

        visit cluster_template_path(@cluster_template.id)
        expect(page).to have_content(@cluster_template.name)
      end
    end
  end
end
