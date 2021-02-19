require 'rails_helper'

RSpec.feature 'Helm Infrastructure Management', type: :feature do
  let(:user_a) { create(:user) }
  before(:each) do
    infrastructure = create(:infrastructure)
    @helm_infrastructure = create(
      :helm_infrastructure,
      app_group: infrastructure.app_group
    )
  end

  describe 'Helm Infrastructure' do
    context 'Edit Helm Infrastructure' do
      scenario 'User can edit Helm Infrastructure' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a

        visit helm_infrastructure_path(@helm_infrastructure)

        click_link 'Edit'
        within('#edit_helm_infrastructure') do
          fill_in 'helm_infrastructure[override_values]', with: '{"key": "hello-1"}'
        end

        click_button 'Submit'
        expect(page).to have_content("hello-1")
      end

      scenario 'User can activate Helm Infrastructure' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a

        visit helm_infrastructure_path(@helm_infrastructure)

        click_link 'Edit'
        within('#edit_helm_infrastructure') do
          check 'helm_infrastructure[is_active]'
        end

        click_button 'Submit'
        expect(page).to have_content("Yes")
      end

      scenario 'User can activate K8s Kibana' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a

        visit helm_infrastructure_path(@helm_infrastructure)

        click_link 'Edit'
        within('#edit_helm_infrastructure') do
          check 'helm_infrastructure[use_k8s_kibana]'
        end

        click_button 'Submit'
        expect(page).to have_content("Yes")
      end

      scenario 'User cannot edit helm infra with invlid override values' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        login_as user_a

        visit helm_infrastructure_path(@helm_infrastructure)

        click_link 'Edit'
        within('#edit_helm_infrastructure') do
          fill_in 'helm_infrastructure[override_values]', with: "\"\""
        end

        click_button 'Submit'
        expect(page).to have_content("Invalid Helm values")
      end
    end
  end
end
