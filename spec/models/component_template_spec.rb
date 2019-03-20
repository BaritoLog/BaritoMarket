require 'rails_helper'

RSpec.describe ComponentTemplate, type: :model do
  context 'Create master data' do
    let(:component_template_props) { build(:component_template) }
    let(:component_template) { create(:component_template) }

    it 'should create the component_template' do
      component_template = ComponentTemplate.create(
        env: Rails.env,
        name: component_template_props.name,
        max_tps: 100,
        instances: component_template_props.instances,
        kafka_options: component_template_props.kafka_options,
      )
      expect(component_template.persisted?).to eq(true)
    end
  end
end
