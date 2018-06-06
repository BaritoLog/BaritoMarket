require 'rails_helper'

RSpec.describe Blueprint, type: :model do
  context 'filename' do
    let(:app) { create :barito_app }
    let(:env) { Rails.env }

    it 'should generate filename' do
      blueprint = Blueprint.new(app, env)
      name = "#{app.cluster_name}_#{Time.now.strftime('%Y%m%d%H%M%S')}"
      expect(blueprint.filename).to eq(name)
    end
  end

  context 'generate_nodes' do
    let(:app) { create :barito_app }
    let(:env) { Rails.env }
    let(:config) { YAML.load_file("#{Rails.root}/config/tps_config.yml") }

    it 'should generate correct number of nodes' do
      blueprint = Blueprint.new(app, env)
      tps_config = config[env][app.tps_config]
      node_count = tps_config['instances'].values.inject(:+)
      expect(node_count).to eq(blueprint.generate_nodes.count)
    end

    it 'should validate node hash' do
      blueprint = Blueprint.new(app, env)
      nodes = blueprint.generate_nodes
      nodes.each do |node|
        expect(node.key?(:name) && node.key?(:type)).to eq(true)
      end
    end

    it 'should validate node name' do
      blueprint = Blueprint.new(app, env)
      tps_config = config[env][app.tps_config]
      nodes = blueprint.generate_nodes
      names = []
      tps_config['instances'].each do |type, count|
        (1..count).each do |number|
          names << "#{blueprint.env_prefix[env.to_sym]}-#{app.cluster_name}-#{type}-" +
            format('%02d', number)
        end
      end
      nodes.each do |node|
        expect(names.include?(node[:name])).to eq(true)
      end
    end
  end

  context 'generate_file' do
    let(:app) { create :barito_app }
    let(:env) { Rails.env }
    let(:config) { YAML.load_file("#{Rails.root}/config/tps_config.yml") }

    before do
      Timecop.freeze
    end

    around(:each) do |example|
      @blueprint = Blueprint.new(app, env)
      @file_path = "#{Rails.root}/blueprints/jobs/#{@blueprint.filename}.json"
      example.run
      File.delete(@file_path) if File.exist?(@file_path)
    end

    it 'should create blueprint file' do
      @blueprint.generate_file
      expect(File.exist?(@file_path)).to eq(true)
    end

    it 'should validate content of blueprint file' do
      nodes = @blueprint.generate_nodes
      @blueprint.generate_file
      content = File.read(@file_path)
      blueprint_content = {
        application_id: app.id,
        cluster_name: app.cluster_name,
        environment: env,
        nodes: nodes,
      }
      expect(content).to eq(blueprint_content.to_json)
    end

    it 'should return file_path' do
      expect(@blueprint.generate_file).to eq(@file_path)
    end
  end
end
