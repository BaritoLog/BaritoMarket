require 'rails_helper'

RSpec.describe BaritoApp, type: :model do
  context 'Setup Application' do
    let(:app_props) { build(:barito_app) }
    before do
      allow(SecureRandom).to receive(:base64).and_return(app_props.secret_key)
      allow(BaritoApp).to receive(:generate_cluster_index).and_return(1000)
      allow(Rufus::Mnemo).to receive(:from_i).with(1000).and_return(
        app_props.cluster_name,
      )
    end
    it 'should create the application' do
      app = BaritoApp.setup(app_props.name, app_props.tps_config, app_props.app_group)
      expect(app.persisted?).to eq(true)
      expect(app.setup_status).to eq(BaritoApp.setup_statuses[:pending].downcase)
      expect(app.app_status).to eq(BaritoApp.app_statuses[:inactive].downcase)
    end

    it 'shouldn\'t create application if app_group is invalid' do
      app = BaritoApp.setup(app_props.name, app_props.tps_config, 'invalid_group')
      expect(app.persisted?).to eq(false)
      expect(app.valid?).to eq(false)
    end

    it 'shouldn\'t create application if tps_config is invalid' do
      app = BaritoApp.setup(app_props.name, 'invalid_config', app_props.app_group)
      expect(app.persisted?).to eq(false)
      expect(app.valid?).to eq(false)
    end

    it 'should generate cluster name' do
      app = BaritoApp.setup(app_props.name, app_props.tps_config, app_props.app_group)
      expect(app.cluster_name).to eq(Rufus::Mnemo.from_i(BaritoApp.generate_cluster_index))
    end

    it 'should generate secret key' do
      app = BaritoApp.setup(app_props.name, app_props.tps_config, app_props.app_group)
      expect(app.secret_key).to eq(app_props.secret_key)
    end
  end

  context 'App Status Update' do
    let(:app) { create(:barito_app) }

    it 'shouldn\'t update status for invalid status type' do
      status_update = app.update_app_status('sample')
      expect(status_update).to eq(false)
    end

    it 'should update app status' do
      status = BaritoApp.app_statuses.keys.sample
      status_update = app.update_app_status(status)
      expect(status_update).to eq(true)
      expect(app.app_status).to eq(status)
    end
  end

  context 'Setup Status Update' do
    let(:app) { create(:barito_app) }

    it 'shouldn\'t update status for invalid status type' do
      status_update = app.update_setup_status('sample')
      expect(status_update).to eq(false)
    end

    it 'should update setup status' do
      status = BaritoApp.setup_statuses.keys.sample
      status_update = app.update_setup_status(status)
      expect(status_update).to eq(true)
      expect(app.setup_status).to eq(status)
    end
  end

  context 'It should get the next cluster index' do
    let(:app) { create(:barito_app) }
    it 'should get the the next cluster index' do
      expect(BaritoApp.generate_cluster_index).to eq(BaritoApp.all.size + 1)
    end
  end
end
