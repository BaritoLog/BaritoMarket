require 'rails_helper'

RSpec.feature 'Cluster Template Management', type: :feature do
  let(:user_a) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    @cluster_template = create(:cluster_template)
  end

  describe 'View cluster template lists' do
    context 'As Superadmin' do
      scenario 'User can see list of cluster templates' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        login_as user_a

        visit cluster_templates_path
        expect(page).to have_content(@cluster_template.name)
      end
    end
  end
end
