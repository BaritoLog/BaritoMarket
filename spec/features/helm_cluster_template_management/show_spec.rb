require 'rails_helper'

RSpec.feature 'Helm Cluster Template Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })
    @helm_cluster_template = create(:helm_cluster_template)
  end

  describe 'View helm cluster template details' do
    context 'As Superadmin' do
      scenario 'User allowed to see helm cluster template details' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        login_as user

        visit helm_cluster_template_path(@helm_cluster_template.id)
        expect(page).to have_content(@helm_cluster_template.name)
      end
    end
  end
end
