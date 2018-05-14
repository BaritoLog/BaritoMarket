require 'rails_helper'

RSpec.describe App, type: :model do
  context 'associations' do
    it 'belongs to app_group' do
      assc = described_class.reflect_on_association(:app_group)
      expect(assc.macro).to eq :belongs_to
    end
  end
  
  context 'name' do
    it 'must be presence' do
      app = FactoryBot.build(:app, name: '')
      expect(app).to_not be_valid
    end
  end

  context 'tps_config_id' do
    it 'must be presence' do
      app = FactoryBot.build(:app, tps_config_id: '')
      expect(app).to_not be_valid
    end
  end

  context 'application secret' do
    it 'generate secret key' do
      app = FactoryBot.create(:app)
      app.generate_secret_key
      expect(app.secret_key.length).to eq(24)
    end
  end

  context 'receiver end point' do
    it 'generate receiver end point' do
      app = FactoryBot.create(:app)
      app.generate_receiver_end_point
      expect(app.receiver_end_point).to eq('http://dummy.end-point/')
    end
  end

  context 'kibana address' do
    it 'generate kibana address' do
      app = FactoryBot.create(:app)
      app.generate_kibana_address
      expect(app.kibana_address).to eq('http://dummy.kibana-address/')
    end
  end

  context 'cluster name' do
    it 'has cluster name after blueprint creation' do
      app = FactoryBot.create(:app, cluster_name: '')
      tps_config = FactoryBot.build(:tps_config)
      chef_configs = FactoryBot.build(:chef_configs)
      blueprint = Blueprint.new(app, tps_config, chef_configs)
      app.set_cluster_name(blueprint.cluster_name)
      expect(app.cluster_name).to eq(blueprint.cluster_name)
    end
  end

  context 'after_create' do
    it 'should has pending setup status' do
      app = FactoryBot.create(:app)
      expect(app.setup_status).to eq('PENDING')
    end
    it 'should has inactive app status' do
      app = FactoryBot.create(:app)
      expect(app.app_status).to eq('INACTIVE')
    end
  end
end
