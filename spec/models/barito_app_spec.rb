require 'rails_helper'

RSpec.describe BaritoApp, type: :model do
  context 'Setup Application' do
    let(:barito_app_props) { build(:barito_app) }

    before do
      allow(SecureRandom).to receive(:uuid).
        and_return(barito_app_props.secret_key)
      allow(BaritoApp).to receive(:generate_cluster_index).and_return(1000)
      allow(Rufus::Mnemo).to receive(:from_i).with(1000).
        and_return(barito_app_props.cluster_name)
    end

    it 'should create the application' do
      barito_app = BaritoApp.setup(
        barito_app_props.name,
        barito_app_props.tps_config,
        barito_app_props.app_group,
        Rails.env,
      )
      expect(barito_app.persisted?).to eq(true)
      expect(barito_app.setup_status).to eq(BaritoApp.setup_statuses[:pending])
      expect(barito_app.app_status).to eq(BaritoApp.app_statuses[:inactive])
    end

    it 'shouldn\'t create application if app_group is invalid' do
      barito_app = BaritoApp.setup(
        barito_app_props.name,
        barito_app_props.tps_config,
        'invalid_group',
        Rails.env,
      )
      expect(barito_app.persisted?).to eq(false)
      expect(barito_app.valid?).to eq(false)
    end

    it 'shouldn\'t create application if tps_config is invalid' do
      barito_app = BaritoApp.setup(
        barito_app_props.name,
        'invalid_config',
        barito_app_props.app_group,
        Rails.env,
      )
      expect(barito_app.persisted?).to eq(false)
      expect(barito_app.valid?).to eq(false)
    end

    it 'should generate cluster name' do
      barito_app = BaritoApp.setup(
        barito_app_props.name,
        barito_app_props.tps_config,
        barito_app_props.app_group,
        Rails.env,
      )
      expect(barito_app.cluster_name).to eq(
        Rufus::Mnemo.from_i(BaritoApp.generate_cluster_index),
      )
    end

    it 'should generate secret key' do
      barito_app = BaritoApp.setup(
        barito_app_props.name,
        barito_app_props.tps_config,
        barito_app_props.app_group,
        Rails.env,
      )
      expect(barito_app.secret_key).to eq(barito_app_props.secret_key)
    end

    it 'should increase log_count' do
      barito_app = create(:barito_app)
      barito_app.increase_log_count(1)
      expect(barito_app.log_count).to eq 1
    end

    it 'should generate blueprint file' do
      barito_app = BaritoApp.setup(
        barito_app_props.name,
        barito_app_props.tps_config,
        barito_app_props.app_group,
        Rails.env,
      )
      blueprint = Blueprint.new(barito_app, Rails.env)
      @file_path = "#{Rails.root}/blueprints/jobs/#{blueprint.filename}.json"
      expect(File.exist?(@file_path)).to eq(true)
    end
  end

  context 'App Status Update' do
    let(:barito_app) { create(:barito_app) }

    it 'shouldn\'t update status for invalid status type' do
      status_update = barito_app.update_app_status('sample')
      expect(status_update).to eq(false)
    end

    it 'should update barito_app status' do
      status = BaritoApp.app_statuses.keys.sample
      status_update = barito_app.update_app_status(status)
      expect(status_update).to eq(true)
      expect(barito_app.app_status.downcase).to eq(status)
    end
  end

  context 'Setup Status Update' do
    let(:barito_app) { create(:barito_app) }

    it 'shouldn\'t update status for invalid status type' do
      status_update = barito_app.update_setup_status('sample')
      expect(status_update).to eq(false)
    end

    it 'should update setup status' do
      status = BaritoApp.setup_statuses.keys.sample
      status_update = barito_app.update_setup_status(status)
      expect(status_update).to eq(true)
      expect(barito_app.setup_status.downcase).to eq(status)
    end
  end

  context 'It should get the next cluster index' do
    let(:barito_app) { create(:barito_app) }
    it 'should get the the next cluster index' do
      expect(BaritoApp.generate_cluster_index).to eq(BaritoApp.all.size + 1000)
    end
  end

  context 'It should validate secret key' do
    let(:barito_app) { create(:barito_app) }
    it 'should return true for a valid key' do
      expect(BaritoApp.secret_key_valid?(barito_app.secret_key)).
        to eq(true)
    end
    it 'should return false for an invalid key' do
      expect(BaritoApp.secret_key_valid?(SecureRandom.base64)).
        not_to eq(true)
    end
  end

  context 'It should generate secret_key' do
    it 'should generate uuid without \'-\'' do
      key = SecureRandom.uuid
      allow(SecureRandom).to receive(:uuid).and_return(key)
      expect(BaritoApp.generate_key).to eq(key.gsub('-', ''))
    end
  end
end
