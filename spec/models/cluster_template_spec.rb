require 'rails_helper'

RSpec.describe ClusterTemplate, type: :model do
  context 'Create master data' do
    let(:cluster_template_props) { build(:cluster_template) }

    it 'should create the cluster_template' do
      cluster_template = ClusterTemplate.create(
        name: cluster_template_props.name,
        instances: cluster_template_props.instances,
        options: cluster_template_props.options,
      )
      
      expect(cluster_template.persisted?).to eq(true)
    end
  end
end
