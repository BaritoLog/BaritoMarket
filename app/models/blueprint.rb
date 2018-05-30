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
    @tps_config = config[env][@app.tps_config]
  end

  def generate_file(env)
    nodes = generate_nodes(env)
    blueprint = {
      application_id: @app.id, cluster_name: @app.cluster_name, environment: env, nodes: nodes
    }
    File.open("#{Rails.root}/blueprints/jobs/#{filename}", 'w+') do |f|
      f.write(blueprint.to_json)
    end
  end

  def generate_nodes(env)
    nodes = []
    @tps_config['instances'].each do |type, count|
      nodes += (1..count).map { |number| node_hash(env, type, number) }
    end
    nodes
  end

  def filename
    "#{@app.cluster_name}_#{Time.now.strftime('%Y%m%d%H%M%S')}"
  end

  private

  def node_hash(env, type, count)
    name = "#{@env_prefix[env.to_s]}-#{@app.cluster_name}-#{type}-#{format('%02d', count.to_i)}"
    { name: name, type: type }
  end
end
