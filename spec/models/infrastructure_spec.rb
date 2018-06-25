require 'rails_helper'

RSpec.describe Infrastructure, type: :model do
  context 'Status Update' do
    let(:infrastructure) { create(:infrastructure) }

    it 'shouldn\'t update status for invalid status type' do
      status_update = infrastructure.update_status('sample')
      expect(status_update).to eq(false)
    end

    it 'should update infrastructure status' do
      status = Infrastructure.statuses.keys.sample
      status_update = infrastructure.update_status(status)
      expect(status_update).to eq(true)
      expect(infrastructure.status.downcase).to eq(status)
    end
  end

  context 'Provisioning Status Update' do
    let(:infrastructure) { create(:infrastructure) }

    it 'shouldn\'t update status for invalid status type' do
      status_update = infrastructure.update_provisioning_status('sample')
      expect(status_update).to eq(false)
    end

    it 'should update provisioning status' do
      status = Infrastructure.provisioning_statuses.keys.sample
      status_update = infrastructure.update_provisioning_status(status)
      expect(status_update).to eq(true)
      expect(infrastructure.provisioning_status.downcase).to eq(status)
    end
  end

  context 'It should generate receiver url' do
    let(:infrastructure) { create(:infrastructure) }
    it 'should generate proper receiver url for logs' do
      url = "#{Figaro.env.router_protocol}://"\
            "#{Figaro.env.router_domain}"\
            '/produce'
      expect(infrastructure.receiver_url).to eq(url)
    end
  end

  context 'It should generate viewer url' do
    let(:infrastructure) { create(:infrastructure) }
    it 'should generate proper viewer url for logs' do
      url = "#{Figaro.env.viewer_protocol}://"\
            "#{infrastructure.cluster_name}.#{Figaro.env.viewer_domain}"
      expect(infrastructure.viewer_url).to eq(url)
    end
  end

  context 'It should get the next cluster index' do
    let(:infrastructure) { create(:infrastructure) }
    it 'should get the the next cluster index' do
      expect(Infrastructure.generate_cluster_index).to eq(Infrastructure.all.size + 1000)
    end
  end
end
