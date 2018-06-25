require 'rails_helper'

RSpec.describe Infrastructure, type: :model do
  context 'Setup Application' do
    let(:infrastructure_props) { build(:infrastructure) }

    before do
      allow(Infrastructure).to receive(:generate_cluster_index).
        and_return(1000)
      allow(Rufus::Mnemo).to receive(:from_i).with(1000).
        and_return(infrastructure_props.cluster_name)
      Sidekiq::Testing.fake!
    end

    it 'should create the infrastructure' do
      infrastructure = Infrastructure.setup(
        infrastructure_props.name,
        infrastructure_props.capacity,
        infrastructure_props.app_group_id,
        Rails.env,
      )
      expect(infrastructure.persisted?).to eq(true)
      expect(infrastructure.provisioning_status).to eq(Infrastructure.provisioning_statuses[:pending])
      expect(infrastructure.status).to eq(Infrastructure.statuses[:inactive])
    end

    it 'shouldn\'t create infrastructure if app_group is invalid' do
      infrastructure = Infrastructure.setup(
        infrastructure_props.name,
        infrastructure_props.capacity,
        'invalid_group',
        Rails.env,
      )
      expect(infrastructure.persisted?).to eq(false)
      expect(infrastructure.valid?).to eq(false)
    end

    it 'shouldn\'t create infrastructure if capacity is invalid' do
      infrastructure = Infrastructure.setup(
        infrastructure_props.name,
        'invalid_config',
        infrastructure_props.app_group_id,
        Rails.env,
      )
      expect(infrastructure.persisted?).to eq(false)
      expect(infrastructure.valid?).to eq(false)
    end

    it 'should generate cluster name' do
      infrastructure = Infrastructure.setup(
        infrastructure_props.name,
        infrastructure_props.capacity,
        infrastructure_props.app_group_id,
        Rails.env,
      )
      expect(infrastructure.cluster_name).to eq(
        Rufus::Mnemo.from_i(Infrastructure.generate_cluster_index),
      )
    end

    it 'should generate blueprint file' do
      infrastructure = Infrastructure.setup(
        infrastructure_props.name,
        infrastructure_props.capacity,
        infrastructure_props.app_group_id,
        Rails.env,
      )
      blueprint = Blueprint.new(infrastructure, Rails.env)
      @file_path = "#{Rails.root}/blueprints/jobs/#{blueprint.filename}.json"
      expect(File.exist?(@file_path)).to eq(true)
    end
  end

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
