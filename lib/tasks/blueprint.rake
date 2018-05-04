require 'fileutils'

namespace :blueprint do
  SSH_CONFIG = "ssh-config"
  
  desc 'blueprint related tasks'
  
  task :exec, [:path] => [:environment] do |t, args|
    path = args[:path]
    begin
      blueprint = Blueprint.create_from_file(path)
    rescue StandardError => e
      puts "Caught the exception: #{e}"
      exit -1
    end
    
    
    if blueprint.provisioning == 'vagrant' 
      node_cnt = 0
    
      blueprint.nodes.each do |node|
        puts "\n\n[#{node.name}] Start provision"
        
        node_dir = "#{blueprint.vagrant.work_dir}/#{node.name}"
        
        id = BlueprintHelper::get_id(node_dir)
        
        if id.empty?
          puts "[#{node.name}] No running vagrant"
          
          FileUtils::mkdir_p node_dir
          
          puts "[#{node.name}] Write the #{node_dir}/Vagrantfile"
          vagrantfile =  BlueprintHelper::vagrantfile({
            :name => node.name,
            :ip_address => "172.10.0.#{2 + node_cnt}",
            :port => "#{10001 + node_cnt}"
          })
          File.open("#{node_dir}/Vagrantfile", "w+") do |file|
            file.write(vagrantfile)
          end
          
          puts "[#{node.name}] Vagrant up"
          BlueprintHelper::vagrant_up(node_dir)
          id = BlueprintHelper::get_id(node_dir)
          
          if id.empty?
            puts "[#{node.name}] Vagrant up is failed. Exit the task."
            exit(1)
          end  
          
          puts "[#{node.name}] Save ssh-config as '#{SSH_CONFIG}'"
          puts BlueprintHelper::save_vagrant_ssh_config(node_dir, SSH_CONFIG)
        end

        puts "[#{node.name}] Vagrant ID: #{id}"
        system "cd #{blueprint.chef_repo} && bundle exec knife solo bootstrap default nodes/#{node.chef_node_config} -F ../#{node_dir}/#{SSH_CONFIG}"
        
        node_cnt += 1
      end
    
    end
  end
  
  
end
