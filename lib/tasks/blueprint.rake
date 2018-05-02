require 'fileutils'

namespace :blueprint do
  desc 'blueprint related tasks'
  
  # task :exec, [:path] => [:environment] do |t, args|
  #   puts "hello"
  # end
  
  task :exec, [:path] => [:environment] do |t, args|
    path = args[:path]
    begin
      file = File.read(path)
      blueprint = JSON.parse(file)
    rescue StandardError => e
      puts "Caught the exception: #{e}"
      exit -1
    end
    
    provisioning = blueprint['provisioning']
    chef_repo_dir = blueprint['chef_repo_dir']
    nodes = blueprint['nodes']
    
    if provisioning == 'vagrant' 
      # work_dir = blueprint['vagrant']['work_dir']
      # nodes.each do |node|
      #   FileUtils::mkdir_p "#{work_dir}/#{node['name']}"
      # end
      
      puts VagrantHelper.vagrantfile({})
      
      # TODO: make vagrant dir
      # TODO: make vagrantfile
      # TODO: vagrantup
    end
    
    # nodes.each do |node|
    #   node = node.symbolize_keys
    #   puts "cd #{chef_repo_dir}"
    # end
  end
  
  
end
