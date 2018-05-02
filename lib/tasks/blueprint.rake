require 'fileutils'

namespace :blueprint do
  desc 'blueprint related tasks'
  
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
      work_dir = blueprint['vagrant']['work_dir']      
      node_cnt = 0
      
      nodes.each do |node|
        node_dir = "#{work_dir}/#{node['name']}"
        vagrantfile =  VagrantHelper::vagrantfile({
          :name => node['name'],
          :ip_address => "172.10.0.#{2 + node_cnt}",
          :port => "#{10001 + node_cnt}"
        })
        
        FileUtils::mkdir_p node_dir
        File.open("#{node_dir}/Vagrantfile", "w+") do |file|
          file.write(vagrantfile)
        end
        
        node_cnt += 1
        
        VagrantHelper::vagrant_up(node_dir)
        puts VagrantHelper::get_id(node_dir)
      end
      
    end
    
    # TODO: run chef bootstrap for each node
    # nodes.each do |node|
    #   node = node.symbolize_keys
    #   puts "cd #{chef_repo_dir}"
    # end
  end
  
  
end
