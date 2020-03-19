require 'rails_helper'
require Rails.root.join('db/migrate/20200317040725_add_manifests_to_cluster_templates')
RSpec.describe AddManifestsToClusterTemplates do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:migrations) { ActiveRecord::MigrationContext.new(migrations_paths).migrations }
  let(:previous_version) { 20200317040713 }
  let(:current_version) { 20200317040725 }

  describe 'when cluster template did not have manifests' do
    before(:each) do
      @cluster_template = create(:cluster_template)
      @cluster_template["instances"].each do |instance|
        create(:component_template, name: instance["type"])
      end
      @cluster_template_consul = create(:cluster_template,
        instances: [{
                      "type": "consul",
                      "count": 1
                    }]
      )

      @cluster_template_elastic = create(:cluster_template,
        instances: [{
                      "type": "elasticsearch",
                      "count": 3
                    }]
      )

      @cluster_template_yggdrasil = create(:cluster_template,
        instances: [{
                      "type": "yggdrasil",
                      "count": 0
                    }]
      )

      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migrator.new(:down, migrations, previous_version).migrate
        ActiveRecord::Migrator.new(:up, migrations, current_version).migrate

        ClusterTemplate.connection.schema_cache.clear!
        ClusterTemplate.reset_column_information
        @cluster_template.reload
        @cluster_template_consul.reload
        @cluster_template_elastic.reload
        @cluster_template_yggdrasil.reload
      end
    end

    context 'Yggdrasil template' do
      it 'should not create yggdrasil manifest' do
        expect(@cluster_template_yggdrasil[:manifests]).to eq({})
      end
    end

    context 'Consul template' do
      it 'create consul manifests' do
        expect(@cluster_template_consul[:manifests]).to_not eq(nil)
      end
      it 'create consul manifests with the correct count' do
        expect(@cluster_template_consul[:manifests][0]["desired_num_replicas"]).to eq(1)
      end

      it 'create consul manifests with the correct minimum available replicas' do
        expect(@cluster_template_consul[:manifests][0]["min_available_replicas"]).to eq(0)
      end

      it 'consul manifests container type should be stateless' do
        expect(@cluster_template_consul[:manifests][0]["definition"]["container_type"]).to eq("stateless")
      end

      it 'consul manifests container type should be allow to failed' do
        expect(@cluster_template_consul[:manifests][0]["definition"]["allow_failure"]).to eq(true)
      end
    end

    context 'Elastic template' do
      it 'create elasticsearch manifests with the correct count' do
        expect(@cluster_template_elastic[:manifests][0]["desired_num_replicas"]).to eq(3)
      end

      it 'create elasticsearch manifests with the correct minimum available replicas' do
        expect(@cluster_template_elastic[:manifests][0]["min_available_replicas"]).to eq(2)
      end

      it 'elasticsearch manifests container type should be stateless' do
        expect(@cluster_template_elastic[:manifests][0]["definition"]["container_type"]).to eq("stateful")
      end

      it 'elasticsearch manifests container type should not be allowed to fail' do
        expect(@cluster_template_elastic[:manifests][0]["definition"]["allow_failure"]).to eq(false)
      end
    end
  end
end
