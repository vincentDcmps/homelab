Vagrant.configure('2') do |config|
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = 'machine'
  end
  config.vm.define "oscar-dev" do |c|
    # Box definition
    c.vm.box = "archlinux/archlinux"
    # Config options
    c.vm.synced_folder ".", "/vagrant", disabled: true
    c.ssh.insert_key = true
    c.vm.hostname = "oscar-dev"
    # Network
    
    # instance_raw_config_args
    # Provider
    c.vm.provider "libvirt" do |libvirt, override|
      
      libvirt.memory = 1024
      libvirt.cpus = 2
    end
  end

  config.vm.define "merlin-dev" do |c|
    # Box definition
    c.vm.box = "generic/rocky9"
    # Config options
    c.vm.synced_folder ".", "/vagrant", disabled: true
    c.ssh.insert_key = true
    c.vm.hostname = "merlin-dev"
    # Network
    # instance_raw_config_args
    # Provider
    c.vm.provider "libvirt" do |libvirt, override|
      
      libvirt.memory = 1024
      libvirt.cpus = 2
           
    end
  end

  config.vm.define "gerard-dev" do |c|
    # Box definition
    c.vm.box = "debian/bookworm64"
    # Config options
    
    c.vm.synced_folder ".", "/vagrant", disabled: true
    c.ssh.insert_key = true
    c.vm.hostname = "gerard-dev"
    # Network
    # instance_raw_config_args
    # Provider
    c.vm.provider "libvirt" do |libvirt, override|
      libvirt.memory = 1024
      libvirt.cpus = 2
    end
  end

  config.vm.define "nas-dev" do |c|
    # Box definition
    c.vm.box = "archlinux/archlinux"
    # Config options
    c.vm.synced_folder ".", "/vagrant", disabled: true   
    c.ssh.insert_key = true
    c.vm.hostname = "nas-dev"
    # Network
    # instance_raw_config_args
    # Provider
    c.vm.provider "libvirt" do |libvirt, override|
      
      libvirt.memory = 1024
      libvirt.cpus = 2
    end
 
    c.vm.provision "ansible" do |bootstrap|
      bootstrap.playbook= "ansible/playbooks/bootstrap.yml"
      bootstrap.galaxy_roles_path= "ansible/roles"
      bootstrap.limit="all"
     { ansible_python_interpreter:"/usr/bin/python3" }
    end
  end
end
