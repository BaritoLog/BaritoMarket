require 'rails_helper'

RSpec.describe ComponentProperty, type: :model do
  context 'Create master data' do
    let(:component_property_props) { build(:component_property) }

    it 'should create the component_property' do
      component_property = ComponentProperty.create(
        name: component_property_props.name,
        component_attributes: component_property_props.component_attributes,
      )
      expect(component_property.persisted?).to eq(true)
    end
  end

  context 'Component propery name should be unique' do
    let(:component_property_props) { build(:component_property) }
    before(:each) do
      @component_property = create(:component_property)
    end

    it 'should not create the component_property' do
      component_property = ComponentProperty.create(
        name: @component_property.name,
        component_attributes: component_property_props.component_attributes,
      )
      expect(component_property.persisted?).to eq(false)
    end
  end
end
