require 'faker'

class Blueprint
  attr_accessor :infrastructure, :capacity, :env_prefix, :env

  def initialize(infrastructure, env)
    @env_prefix = {
      production: 'p', staging: 's', development: 'd', uat: 'u', internal: 'i',
      integration: 'g', test: 't'
    }
    config = YAML.load_file("#{Rails.root}/config/tps_config.yml")
    @infrastructure = infrastructure
    @env = env
    @capacity = config[@env][@infrastructure.capacity]
  end

  def generate_file
    nodes = generate_nodes
    blueprint = {
      infrastructure_id: @infrastructure.id, cluster_name: @infrastructure.cluster_name, environment: @env, nodes: nodes
    }
    filepath = "#{Rails.root}/blueprints/jobs/#{filename}.json"
    File.open(filepath, 'w+') do |f|
      f.write(blueprint.to_json)
    end
    filepath
  end

  def generate_nodes
    nodes = []
    @capacity['instances'].each do |type, count|
      nodes += (1..count).map { |number| node_hash(type, number) }
    end
    nodes
  end

  def filename
    "#{@infrastructure.cluster_name}_#{Time.now.strftime('%Y%m%d%H%M%S')}"
  end

  private

  def node_hash(type, count)
    name = "#{@env_prefix[@env.to_sym]}-#{@infrastructure.cluster_name}-#{type}-#{format('%02d', count.to_i)}"
    { name: name, type: type }
  end
end
