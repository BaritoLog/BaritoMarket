require 'rails_helper'
require Rails.root.join('db/migrate/20210623000000_add_infrastructure_fields_to_helm_infrastructure')
RSpec.describe AddInfrastructureFieldsToHelmInfrastructure do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:migrations) { ActiveRecord::MigrationContext.new(migrations_paths).migrations }
  let(:previous_version) { 20210530003000 }
  let(:current_version) { 20210623000000 }

  describe 'Running add infrastructure fields to helm infrastructure' do
    before(:each) do
      helm_cluster_template = create(:helm_cluster_template, name: 'helm_cluster_template_1')

      @infrastructure_1 = create(:infrastructure, name: 'Infrastructure_1')
      @infrastructure_2 = create(:infrastructure, name: 'Infrastructure_2')
      @helm_infra_1 = create(:helm_infrastructure, 
        app_group: @infrastructure_1.app_group, helm_cluster_template: helm_cluster_template)
      @helm_infra_2 = create(:helm_infrastructure, 
        app_group: @infrastructure_2.app_group, helm_cluster_template: helm_cluster_template)

      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migrator.new(:down, migrations, previous_version).migrate
        ActiveRecord::Migrator.new(:up, migrations, current_version).migrate
        
        HelmInfrastructure.connection.schema_cache.clear!
        HelmInfrastructure.reset_column_information
      end
    end

    context 'Copy value from infra 1 to helm infra' do
      before(:each) do
        @helm_infra_1.reload
      end

      it 'has helm_infra_1' do
        expect(@helm_infra_1).to_not eq(nil)
      end
      
      it 'copies the correct cluster_name for helm_infra_1' do
        expect(@helm_infra_1.cluster_name).to eq(@infrastructure_1.cluster_name)
      end
      
      it 'copies the correct status for helm_infra_1' do
        expect(@helm_infra_1.status).to eq(@infrastructure_1.status)
      end
      
      it 'copies the correct provisioning_status for helm_infra_1' do
        expect(@helm_infra_1.provisioning_status).to eq(@infrastructure_1.provisioning_status)
      end
      
      it 'copies the correct max_tps for helm_infra_1' do
        expect(@helm_infra_1.max_tps).to eq(@infrastructure_1.options['max_tps'].to_i)
      end
    end

    context 'Copy value from infra 2 to helm infra' do
      before(:each) do
        @helm_infra_2.reload
      end

      it 'has helm_infra_2' do
        expect(@helm_infra_2).to_not eq(nil)
      end
      
      it 'copies the correct cluster_name for helm_infra_2' do
        expect(@helm_infra_2.cluster_name).to eq(@infrastructure_2.cluster_name)
      end
      
      it 'copies the correct status for helm_infra_2' do
        expect(@helm_infra_2.status).to eq(@infrastructure_2.status)
      end
      
      it 'copies the correct provisioning_status for helm_infra_2' do
        expect(@helm_infra_2.provisioning_status).to eq(@infrastructure_2.provisioning_status)
      end
      
      it 'copies the correct max_tps for helm_infra_2' do
        expect(@helm_infra_2.max_tps).to eq(@infrastructure_2.options['max_tps'].to_i)
      end
    end
  end
end