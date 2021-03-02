require 'rails_helper'

RSpec.feature 'Helm Infrastructure Management', type: :feature do
  let(:user) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    infrastructure = create(:infrastructure)
    @helm_infrastructure = create(
      :helm_infrastructure,
      app_group: infrastructure.app_group
    )
  end

  describe 'View helm cluster template details' do
    context 'As Superadmin' do
      scenario 'User allowed to see helm cluster template details' do
        set_check_user_groups({ 'groups' => ['barito-superadmin'] })
        login_as user

        visit helm_infrastructure_path(@helm_infrastructure.id)
        expect(page).to have_content(@helm_infrastructure.app_group.name)
      end
    end
  end
end
