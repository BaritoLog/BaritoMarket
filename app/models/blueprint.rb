require 'faker'

class Blueprint
  attr_accessor :app, :tps_config, :env_prefix, :env

  def initialize(application, env)
    @env_prefix = {
      production: 'p', staging: 's', development: 'd', uat: 'u', internal: 'i',
      integration: 'g', test: 't'
    }
    config = YAML.load_file("#{Rails.root}/config/tps_config.yml")
    @app = application
    @env = env
    @tps_config = config[@env][@app.tps_config]
  end

  def generate_file
    nodes = generate_nodes
    blueprint = {
      application_id: @app.id, cluster_name: @app.cluster_name, environment: @env, nodes: nodes
    }
    filepath = "#{Rails.root}/blueprints/jobs/#{filename}.json"
    File.open(filepath, 'w+') do |f|
      f.write(blueprint.to_json)
    end
    filepath
  end

  def generate_nodes
    nodes = []
    @tps_config['instances'].each do |type, count|
      nodes += (1..count).map { |number| node_hash(type, number) }
    end
    nodes
  end

  def filename
    "#{@app.cluster_name}_#{Time.now.strftime('%Y%m%d%H%M%S')}"
  end

  private

  def node_hash(type, count)
    name = "#{@env_prefix[@env.to_sym]}-#{@app.cluster_name}-#{type}-#{format('%02d', count.to_i)}"
    { name: name, type: type }
  end
end
