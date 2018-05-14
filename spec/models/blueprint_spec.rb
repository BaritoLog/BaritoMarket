require 'rails_helper'

RSpec.describe Blueprint, type: :model do

  let (:app) {build :app}
  let (:tps_config) {build :tps_config}
  let (:chef_configs) {build :chef_configs}

  context 'blueprint creation' do
    it 'has application' do
      blueprint = Blueprint.new(app, tps_config, chef_configs)
      expect(blueprint.application).to eq(app)
    end

    it 'has tps_config' do
      blueprint = Blueprint.new(app, tps_config, chef_configs)
      expect(blueprint.tps_config['name']).to eq('Small')
    end

    it 'generate cluster name' do
      blueprint = Blueprint.new(app, tps_config, chef_configs)
      expect(blueprint.cluster_name).to_not be_empty
    end

    it 'has cluster name not longer than 4 chars' do
      blueprint = Blueprint.new(app, tps_config, chef_configs)
      expect(blueprint.cluster_name.length).to eq(4)
    end

    it 'has blueprint hash' do
      blueprint = Blueprint.new(app, tps_config, chef_configs)
      blueprint.create_blueprint

      expect(blueprint.blueprint).to_not be_nil
    end

    it 'has nodes hash' do
      blueprint = Blueprint.new(app, tps_config, chef_configs)

      expect(blueprint.nodes).to_not be_nil
    end
  end
end