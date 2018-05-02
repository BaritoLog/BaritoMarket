class Blueprint
  attr_accessor :provisioning, :vagrant, :chef_repo_dir, :nodes
  
  def initialize args
    @provisioning = args['provisioning']
    @chef_repo_dir = args['chef_repo_dir']
    @vagrant = BlueprintVagrant.new(args['vagrant'])
    @nodes = []
    args['nodes'].each do |node|
      @nodes << BlueprintNode.new(node)
    end
  end
  
  def self.create_from_file(path)
    file = File.read(path)
    hash = JSON.parse(file)
    
    Blueprint.new(hash)
  end
end
