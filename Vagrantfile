MASTER_COUNT = 1
NODE_COUNT   = 2
IMAGE        = "centos/7"
PROJECT      = File.dirname(File.expand_path(__FILE__)).split("/").last.gsub(" ", "-")

Vagrant.configure("2") do |config|
  (1..MASTER_COUNT).each do |i|
    config.vm.define "#{PROJECT}-master#{i}" do |master|
      master.vm.box = IMAGE
      master.vm.hostname = "master#{i}"
      master.vm.network :private_network, ip: "192.168.56.#{50 + i}"

      # disk_name = "master#{i}-docker.vdi"

      master.vm.provider :virtualbox do |v|
        v.linked_clone = true

        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["modifyvm", :id, "--memory", 2048]
        v.customize ["modifyvm", :id, "--vram", 8]
        v.customize ["modifyvm", :id, "--name", "#{PROJECT}-master#{i}"]
        # v.customize ["storagectl", :id, "--name", "SATA", "--hostiocache", "on"]

        # unless File.exist?(disk_name)
        #   v.customize ['createhd', '--filename', disk_name, '--size', 500 * 1024]
        # end
        #
        # v.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk_name]
      end

      master.vm.provision :ansible do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "ansible/common.yml"
        ansible.extra_vars = {
          MASTER_COUNT: "#{MASTER_COUNT}",
          NODE_COUNT: "#{NODE_COUNT}"
        }
      end
    end
  end

  (1..NODE_COUNT).each do |i|
    config.vm.define "#{PROJECT}-node#{i}" do |node|
      node.vm.box = IMAGE
      node.vm.hostname = "node#{i}"
      node.vm.network :private_network, ip: "192.168.56.#{60 + i}"

      # disk_name = "node#{i}-docker.vdi"

      node.vm.provider :virtualbox do |v|
        v.linked_clone = true

        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["modifyvm", :id, "--memory", 1024]
        v.customize ["modifyvm", :id, "--vram", 8]
        v.customize ["modifyvm", :id, "--name", "#{PROJECT}-node#{i}"]
        # v.customize ["storagectl", :id, "--name", "SATA", "--hostiocache", "on"]

        # unless File.exist?(disk_name)
        #   v.customize ['createhd', '--filename', disk_name, '--size', 500 * 1024]
        # end
        #
        # v.customize ['storageattach', :id, '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', disk_name]
      end

      node.vm.provision :ansible do |ansible|
        ansible.compatibility_mode = "2.0"
        ansible.playbook = "ansible/common.yml"
        ansible.extra_vars = {
          MASTER_COUNT: "#{MASTER_COUNT}",
          NODE_COUNT: "#{NODE_COUNT}"
        }
      end
    end
  end
end
