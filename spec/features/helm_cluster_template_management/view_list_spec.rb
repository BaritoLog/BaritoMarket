require 'rails_helper'

RSpec.feature 'Helm Cluster Template Management', type: :feature do
  let(:user_a) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    @helm_cluster_template = create(:helm_cluster_template)
  end

  describe 'View helm cluster template lists' do
    context 'As Superadmin' do
      scenario 'User can see list of helm cluster templates' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        login_as user_a

        visit helm_cluster_templates_path
        expect(page).to have_content(@helm_cluster_template.name)
      end
    end
  end
end
