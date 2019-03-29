require 'rails_helper'

RSpec.describe BaritoApp, type: :model do
  context 'Setup Application' do
    let(:barito_app_props) { build(:barito_app) }

    it 'should create the barito_app' do
      barito_app = BaritoApp.setup(
        app_group_id: barito_app_props.app_group_id,
        name: barito_app_props.name,
        topic_name: barito_app_props.topic_name,
        secret_key: BaritoApp.generate_key,
        max_tps: barito_app_props.max_tps,
        status: BaritoApp.statuses[:active],
      )
      
      expect(barito_app.persisted?).to eq(true)
      expect(barito_app.status).to eq(BaritoApp.statuses[:active])
    end

    it 'should replace space with hyphen for topic name' do
      barito_app = BaritoApp.setup(
        app_group_id: barito_app_props.app_group_id,
        name: barito_app_props.name,
        topic_name: 'test topic name',
        secret_key: BaritoApp.generate_key,
        max_tps: barito_app_props.max_tps,
        status: BaritoApp.statuses[:active],
      )
      
      expect(barito_app.topic_name).to eq('test-topic-name')
    end
  end

  context 'Status Update' do
    let(:barito_app) { create(:barito_app) }

    it 'shouldn\'t update status for invalid status type' do
      status_update = barito_app.update_status('sample')
      
      expect(status_update).to eq(false)
    end

    it 'should update barito_app status' do
      status = BaritoApp.statuses.keys.sample
      status_update = barito_app.update_status(status)
      
      expect(status_update).to eq(true)
      expect(barito_app.status.downcase).to eq(status)
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

  context 'It should get the app group name' do
    let(:barito_app) { create(:barito_app) }
    it 'should return the app group name' do
      expect(barito_app.app_group_name).to eq(barito_app.app_group.name)
    end
  end

  context 'It should get the cluster name' do
    let(:infrastructure) { create(:infrastructure) }
    let(:barito_app) {
      create(:barito_app, app_group: infrastructure.app_group) }
    it 'should return the cluster name' do
      expect(barito_app.cluster_name).
        to eq(barito_app.app_group.infrastructure.cluster_name)
    end
  end

  context 'It should get the consul host' do
    let(:infrastructure) { create(:infrastructure) }
    let(:barito_app) {
      create(:barito_app, app_group: infrastructure.app_group) }
    it 'should return the consul host' do
      expect(barito_app.consul_host).
        to eq(barito_app.app_group.infrastructure.consul_host)
    end
  end
end
