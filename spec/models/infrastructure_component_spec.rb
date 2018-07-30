require 'rails_helper'

RSpec.describe InfrastructureComponent, type: :model do

  context 'Add Infrastructure Component' do
    let(:infrastructure) { create :infrastructure }
    let(:env) { Rails.env }
    before(:each) do
      @blueprint = Blueprint.new(infrastructure, env)
      @nodes = @blueprint.generate_nodes
    end


    it 'should generate correct number of components' do
      infrastructure_components = []
      @nodes.each_with_index do |node, seq|
        infrastructure_components << InfrastructureComponent.add(infrastructure, node, seq)
      end
      expect(infrastructure_components.count).to eq(@nodes.count)
    end

    it 'should validate infrastructure components' do
      @nodes.each_with_index do |node, seq|
        component = InfrastructureComponent.add(infrastructure, node, seq)
        expect(component.hostname? && component.category?).to eq(true)
      end
    end

    it 'should validate hostname' do
      infrastructure_components = []
      names = []
      @nodes.each_with_index do |node, seq|
        names << node[:name]
        infrastructure_components << InfrastructureComponent.add(infrastructure, node, seq)
      end
      infrastructure_components.each do |component|
        expect(names.include?(component.hostname)).to eq(true)
      end
    end
  end

  context 'Status Update' do
    let(:infrastructure_component) { create(:infrastructure_component) }

    it 'shouldn\'t update status for invalid status type' do
      status_update = infrastructure_component.update_status('sample')
      expect(status_update).to eq(false)
    end

    it 'should update infrastructure_component status' do
      status = InfrastructureComponent.statuses.keys.sample
      status_update = infrastructure_component.update_status(status)
      expect(status_update).to eq(true)
      expect(infrastructure_component.status.downcase).to eq(status)
    end

    it 'should update infrastructure_component message with status if there is no message from response' do
      status = InfrastructureComponent.statuses.keys.sample
      status_update = infrastructure_component.update_status(status)
      expect(status_update).to eq(true)
      expect(infrastructure_component.message.downcase).to eq(status)
    end

    it 'should update infrastructure_component message' do
      message = '{"success": "200"}'
      status = InfrastructureComponent.statuses.keys.sample
      status_update = infrastructure_component.update_status(status, message)
      expect(status_update).to eq(true)
      expect(infrastructure_component.message).to eq(message)
    end
  end
end
