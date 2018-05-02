module VagrantHelper
  
  def self.vagrantfile(new_vagrant_config)
    vagrant_config = {
      :name => "default",
      :memory => 512,
      :cpus => 1,
      :vm_box => "ubuntu/xenial64",
      :ip_address => "172.10.0.2",
      :port => "8080",
    }
    vagrant_config = vagrant_config.merge(new_vagrant_config)
    
    vagrant_file = File.read(Rails.root.join('app','templates') + "vagrant_file.erb")
    b = binding
    b.local_variable_set(:vagrant_config, vagrant_config)
    
    ERB.new(vagrant_file).result(b)
  end
  
  def self.get_id(vagrant_dir)
    `vagrant global-status | grep #{vagrant_dir} | awk '{print $1}'`
  end
  
  def self.vagrant_up(vagrant_dir)
    `cd #{vagrant_dir} && vagrant up`
  end
end
