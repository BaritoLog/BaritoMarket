require 'rails_helper'

RSpec.describe Infrastructure, type: :model do
  describe 'Add Infrastructure Component' do
    let(:infrastructure) { create :infrastructure }
    let(:env) { Rails.env }
    before(:each) do
      @blueprint = Blueprint.new(infrastructure, env)
      @nodes = @blueprint.generate_nodes
    end

    it 'should generate correct number of components' do
      @nodes.each_with_index do |node, seq|
        infrastructure.add_component(node, seq + 1)
      end
      expect(infrastructure.infrastructure_components.count).
        to eq(@nodes.count)
    end
  end

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
        Rails.env,
        name: infrastructure_props.name,
        capacity: infrastructure_props.capacity,
        app_group_id: infrastructure_props.app_group_id,
      )
      expect(infrastructure.persisted?).to eq(true)
      expect(infrastructure.provisioning_status).to eq(Infrastructure.provisioning_statuses[:pending])
      expect(infrastructure.status).to eq(Infrastructure.statuses[:inactive])
    end

    it 'shouldn\'t create infrastructure if app_group is invalid' do
      infrastructure = Infrastructure.setup(
        Rails.env,
        name: infrastructure_props.name,
        capacity: infrastructure_props.capacity,
        app_group_id: 'invalid_group',
      )
      expect(infrastructure.persisted?).to eq(false)
      expect(infrastructure.valid?).to eq(false)
    end

    it 'shouldn\'t create infrastructure if capacity is invalid' do
      infrastructure = Infrastructure.setup(
        Rails.env,
        name: infrastructure_props.name,
        capacity: 'invalid_config',
        app_group_id: infrastructure_props.app_group_id,
      )
      expect(infrastructure.persisted?).to eq(false)
      expect(infrastructure.valid?).to eq(false)
    end

    it 'should generate cluster name' do
      infrastructure = Infrastructure.setup(
        Rails.env,
        name: infrastructure_props.name,
        capacity: infrastructure_props.capacity,
        app_group_id: infrastructure_props.app_group_id,
      )
      expect(infrastructure.cluster_name).to eq(
        Rufus::Mnemo.from_i(Infrastructure.generate_cluster_index),
      )
    end

    it 'should generate blueprint file' do
      infrastructure = Infrastructure.setup(
        Rails.env,
        name: infrastructure_props.name,
        capacity: infrastructure_props.capacity,
        app_group_id: infrastructure_props.app_group_id,
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

  context 'It should get the app group name' do
    let(:infrastructure) { create(:infrastructure) }
    it 'should return the app group name' do
      expect(infrastructure.app_group_name).to eq(infrastructure.app_group.name)
    end
  end

  context 'It should get the next cluster index' do
    let(:infrastructure) { create(:infrastructure) }
    it 'should get the the next cluster index' do
      expect(Infrastructure.generate_cluster_index).to eq(Infrastructure.all.size + 1000)
    end
  end

  describe '#allow_delete?' do
    let(:infrastructure_props) { build(:infrastructure) }

    it 'should return true if infrastructure can be deleted' do
      infrastructure = Infrastructure.setup(
        Rails.env,
        name: infrastructure_props.name,
        capacity: infrastructure_props.capacity,
        app_group_id: infrastructure_props.app_group_id
      )
      infrastructure.update_status('INACTIVE')
      infrastructure.update_provisioning_status('FINISHED')
      expect(infrastructure.allow_delete?).to eq true
    end

    it 'should return false if infrastructure cannot be deleted' do
      infrastructure = Infrastructure.setup(
        Rails.env,
        name: infrastructure_props.name,
        capacity: infrastructure_props.capacity,
        app_group_id: infrastructure_props.app_group_id
      )
      infrastructure.update_status('ACTIVE')
      infrastructure.update_provisioning_status('FINISHED')
      expect(infrastructure.allow_delete?).to eq false
    end
  end
end
