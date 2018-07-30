require 'rails_helper'

RSpec.describe InfrastructureComponent, type: :model do
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
