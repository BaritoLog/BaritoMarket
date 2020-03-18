require 'rails_helper'
require Rails.root.join('db/migrate/20200317040713_add_manifests_to_infrastructures')

RSpec.describe AddManifestsToInfrastructures do
  let(:migrations_paths) { ActiveRecord::Migrator.migrations_paths }
  let(:migrations) { ActiveRecord::MigrationContext.new(migrations_paths).migrations }
  let(:previous_version) { 20200127094355 }
  let(:current_version) { 20200317040713 }

  around do |example|
    ActiveRecord::Migration.suppress_messages do
      example.run
    end
  end

  context 'when an infrastructure has components' do
    before(:each) do
      @infrastructure = create(:infrastructure)
      create(:infrastructure_component, infrastructure: @infrastructure,
                                        component_type: "elasticsearch")
      create(:infrastructure_component, infrastructure: @infrastructure,
                                        component_type: "elasticsearch")
      create(:infrastructure_component, infrastructure: @infrastructure,
                                        component_type: "elasticsearch")
      create(:infrastructure_component, infrastructure: @infrastructure,
                                        component_type: "kibana")
      create(:infrastructure_component, infrastructure: @infrastructure,
                                        component_type: "zookeeper",
                                        bootstrappers: [
                                          {
                                            bootstrap_type: "chef-solo",
                                            bootstrap_attributes: {
                                              consul: {
                                                hosts: [],
                                              },
                                              zookeeper: {
                                                hosts: [
                                                  "1.zookeeper.service.consul",
                                                  "2.zookeeper.service.consul",
                                                  "0.0.0.0",
                                                ],
                                                my_id: 3
                                              }
                                            },
                                          },
                                        ])

      ActiveRecord::Migrator.new(:down, migrations, previous_version).migrate
      ActiveRecord::Migrator.new(:up, migrations, current_version).migrate
      Infrastructure.connection.schema_cache.clear!
      Infrastructure.reset_column_information
      @infrastructure.reload
    end

    it 'has correct component_type' do
      manifest_names = @infrastructure.manifests.map { |manifest| manifest["name"] }
      desired_manifest_names = [
        "elasticsearch", "kibana", "zookeeper"
      ].map { |component_type| "#{@infrastructure.cluster_name}-#{component_type}" }

      expect(manifest_names).to match_array(desired_manifest_names)
    end

    context 'elasticsearch manifest' do
      let(:manifest) do
        @infrastructure.manifests.select { |manifest|
          manifest["name"] == "#{@infrastructure.cluster_name}-elasticsearch"
        }.first
      end

      it 'has correct desired_num_replicas' do
        expect(manifest["desired_num_replicas"]).to eq(3)
      end

      it 'has correct min_available_replicas' do
        expect(manifest["min_available_replicas"]).to eq(2)
      end

      it 'has correct definition.container_type' do
        expect(manifest["definition"]["container_type"]).to eq("stateful")
      end

      it 'has correct definition.allow_failure' do
        expect(manifest["definition"]["allow_failure"]).to eq(false)
      end
    end

    context 'kibana manifest' do
      let(:manifest) do
        @infrastructure.manifests.select { |manifest|
          manifest["name"] == "#{@infrastructure.cluster_name}-kibana"
        }.first
      end

      it 'has correct definition.container_type' do
        expect(manifest["definition"]["container_type"]).to eq("stateless")
      end

      it 'has correct definition.allow_failure' do
        expect(manifest["definition"]["allow_failure"]).to eq(true)
      end

      it 'has Pathfinder script as its Consul IP addresses' do
        bootstrapper = manifest["definition"]["bootstrappers"][0]
        expect(bootstrapper["bootstrap_attributes"]["consul"]["hosts"]).to eq(
          "$pf-meta:deployment_ip_addresses?deployment_name=#{@infrastructure.cluster_name}-consul"
        )
      end
    end

    context 'zookeeper manifest' do
      let(:manifest) do
        @infrastructure.manifests.select { |manifest|
          manifest["name"] == "#{@infrastructure.cluster_name}-zookeeper"
        }.first
      end

      it 'has Pathfinder script as Zookeeper my_id' do
        bootstrapper = manifest["definition"]["bootstrappers"][0]
        expect(bootstrapper["bootstrap_attributes"]["zookeeper"]["my_id"]).to eq(
          "$pf-meta:container_id"
        )
      end

      it 'has Pathfinder script as Zookeeper hosts' do
        bootstrapper = manifest["definition"]["bootstrappers"][0]
        expect(bootstrapper["bootstrap_attributes"]["zookeeper"]["hosts"]).to eq(
          "$pf-meta:deployment_host_sequences?host=zookeeper.service.consul"
        )
      end
    end
  end
end
