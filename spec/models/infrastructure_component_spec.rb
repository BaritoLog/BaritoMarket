require 'rails_helper'

RSpec.describe InfrastructureComponent, type: :model do
  describe '#update_status' do
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

  describe '#allow_provision?' do
    let(:infrastructure_component) { 
      build(:infrastructure_component, status: 'PROVISIONING_ERROR') 
    }

    it 'should return true if component provisioning can be retried' do
      expect(infrastructure_component.allow_provision?).to eq true
    end
  end

  describe '#allow_bootstrap?' do
    let(:infrastructure_component) { 
      build(:infrastructure_component, status: 'BOOTSTRAP_ERROR') 
    }

    it 'should return true if component bootstrapping can be retried' do
      expect(infrastructure_component.allow_bootstrap?).to eq true
    end
  end
end
