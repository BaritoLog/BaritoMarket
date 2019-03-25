require 'rails_helper'

RSpec.describe ClusterTemplate, type: :model do
  context 'Create master data' do
    let(:cluster_template_props) { build(:cluster_template) }
    let(:cluster_template) { create(:cluster_template) }

    it 'should create the cluster_template' do
      cluster_template = ClusterTemplate.create(
        env: Rails.env,
        name: cluster_template_props.name,
        max_tps: 100,
        instances: cluster_template_props.instances,
        kafka_options: cluster_template_props.kafka_options,
      )
      expect(cluster_template.persisted?).to eq(true)
    end
  end
end
