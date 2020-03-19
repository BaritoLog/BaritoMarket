require 'rails_helper'
require Rails.root.join('db/migrate/20200317064025_create_deployment_templates')
RSpec.describe CreateDeploymentTemplates do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:migrations) { ActiveRecord::MigrationContext.new(migrations_paths).migrations }
  let(:previous_version) { 20200317040725 }
  let(:current_version) { 20200317064025 }

  describe 'Running create deployment template migration' do
    before(:each) do
      @component_template_1 = create(:component_template, name: 'template_1')
      @component_template_2 = create(:component_template, name: 'template_2')
      
      @component_template = ComponentTemplate.all
      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migrator.new(:down, migrations, previous_version).migrate
        ActiveRecord::Migrator.new(:up, migrations, current_version).migrate
        
        DeploymentTemplate.connection.schema_cache.clear!
        DeploymentTemplate.reset_column_information
      end
      @deployment_templates = DeploymentTemplate.all
    end
    
    context 'component template exists' do
      it 'create the correct amount of deployment templates' do
        expect(@deployment_templates.count).to eq(@component_template.count)
      end
    end

    context 'component template 1' do
      before(:each) do
        @deployment_template_1 = DeploymentTemplate.find_by(name: @component_template_1.name)
      end

      it 'has template_1' do
        expect(@deployment_template_1).to_not eq(nil)
      end
      
      it 'copies the correct source for component 1' do
        expect(@deployment_template_1.source).to eq(@component_template_1.source)
      end
      
      it 'copies the correct bootstrappers for component 1' do
        expect(@deployment_template_1.bootstrappers).to eq(@component_template_1.bootstrappers)
      end
    end

    context 'component template 2' do
      before(:each) do
        @deployment_template_2 = DeploymentTemplate.find_by(name: @component_template_2.name)
      end

      it 'has template_2' do
        expect(@deployment_template_2).to_not eq(nil)
      end
      
      it 'copies the correct source for component 1' do
        expect(@deployment_template_2.source).to eq(@component_template_2.source)
      end
      
      it 'copies the correct bootstrappers for component 1' do
        expect(@deployment_template_2.bootstrappers).to eq(@component_template_2.bootstrappers)
      end
    end
  end
end