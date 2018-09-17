Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.disksize.size = '20GB'

  config.vm.provider "virtualbox" do |vb|
     vb.memory = "6288"
  end

  config.vm.provision "shell", path: "bootstrap.sh"
end
