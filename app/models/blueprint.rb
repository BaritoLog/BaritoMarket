require 'faker'

class Blueprint
  # attr_accessor :provisioning, :vagrant, :chef_repo, :nodes
  attr_accessor :blueprint, :application, :tps_config, :chef_config, :nodes, :cluster_name

  def blueprint_hash
    {
        'application_id': @application.id,
        'cluster_name': @cluster_name,
        'environment': Rails.env,
        'application_tps': @application.tps_config_id,
        'nodes': @nodes
    }
  end

  def node_hash(node_name, node_type, run_list, chef_repo, container_config)
    {
        "name": node_name,
        "type": node_type,
        "run_list": run_list,
        "chef_repo": chef_repo,
        "node_container_config": container_config
    }
  end

  # def initialize args
  #   @provisioning = args['provisioning']
  #   @chef_repo = args['chef_repo']
  #   @vagrant = BlueprintVagrant.new(args['vagrant'])
  #   @nodes = []
  #   args['nodes'].each do |node|
  #     @nodes << BlueprintNode.new(node)
  #   end
  # end
  def initialize(application, tps_config, chef_config)
    @application = application
    @tps_config = tps_config.get(application.tps_config_id)
    @chef_config = chef_config
    @cluster_name = generate_cluster_name

    create_nodes
    create_blueprint
  end

  # def self.create_from_file(path)
  #   file = File.read(path)
  #   hash = JSON.parse(file)
  #
  #   Blueprint.new(hash)
  # end

  def generate_cluster_name
    Faker::Internet.user_name(4..4)
  end

  def create_blueprint
    @blueprint = blueprint_hash
  end

  def create_nodes
    nodes = []
    available_instances = Figaro.env.provision_available_instances.split(',')
    available_instances.each do |instance|
      number_of_instance = @tps_config[instance + '_instances']
      unless not number_of_instance.present?
        chef_config = @chef_config.get(instance)
        run_list = chef_config['run_list']
        chef_repo = chef_config['chef_repo']
        (1..number_of_instance).each do |number|
          nodes << node_hash(generate_node_name(instance, number), instance, run_list, chef_repo, @application.tps_config_id)
        end
      end
    end
    @nodes = nodes
  end

  def to_file
    time = Time.now.strftime("%Y%m%d%H%M%S")
    filename = "#{@cluster_name}_#{time}.json"
    File.open("#{Rails.root.to_s}/blueprints/jobs/#{filename}", "w+") do |f|
      f.write(JSON.pretty_generate(@blueprint))
    end
  end

  def generate_node_name(type, counter)
    short_env_name = ''
    case Rails.env
      when 'production'
        short_env_name = 'p'
      when 'staging'
        short_env_name = 's'
      when 'development'
        short_env_name = 'd'
      when 'uat'
        short_env_name = 'u'
      when 'internal'
        short_env_name = 'i'
      when 'integration'
        short_env_name = 'g'
    end

    short_env_name + '-' + @cluster_name + '-' + type + '-' + format('%02d', counter.to_i)
  end
end
