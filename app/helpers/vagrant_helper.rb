class VagrantHelper
  
  def self.vagrantfile(new_vagrant_config)
    vagrant_config = {
      :vm_box => "ubuntu/xenial64",
      :ip_address => "172.10.0.2",
      :port => "8080",
    }
    vagrant_config.merge(new_vagrant_config)
    
    vagrant_file = File.read(Rails.root.join('app','templates') + "vagrant_file.erb")
    b = binding
    b.local_variable_set(:vagrant_config, vagrant_config)
    
    ERB.new(vagrant_file).result(b)
  end
end
