ENV["LC_ALL"] = "en_US.UTF-8"

# if sth. gets changed here, also adapt /ansible/inventories/vbox/hosts
KAFKA = 3
CASSANDRA = 3
HADDOP = 3

Vagrant.configure("2") do |config|

  required_plugins = %w( vagrant-hostsupdater )
  required_plugins.each do |plugin|
    system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
  end

  config.vm.box = "markush81/centos7-vbox-guestadditions"
  config.vm.box_check_update = true

  config.vm.synced_folder "download", "/vagrant/download", create: true
  config.vm.synced_folder "exchange", "/home/vagrant/exchange", create: true
  config.vm.synced_folder "ansible", "/home/vagrant/ansible", create: true

  config.vm.provision :shell, inline: "ifup eth1", run: "always"

  (1..KAFKA).each do |i|
    config.vm.define "kafka-#{i}" do |kafka|
      kafka.vm.hostname = "kafka-#{i}"
      kafka.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = "1"
      end
      kafka.vm.network :private_network, ip: "192.168.10.#{1 + i}", auto_config: true

      if i == KAFKA

        kafka.vm.provision :ansible do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.limit = "network"
          ansible.playbook = "ansible/network.yml"
          ansible.inventory_path = "ansible/inventories/vbox"
          ansible.raw_arguments  = [
            "-vv"
          ]
        end

        kafka.vm.provision :ansible do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.limit = "zookeeper,kafka"
          ansible.playbook = "ansible/cluster.yml"
          ansible.inventory_path = "ansible/inventories/vbox"
          ansible.raw_arguments  = [
            "-vv"
          ]
        end
      end
    end
  end

  (1..CASSANDRA).each do |i|
    config.vm.define "cassandra-#{i}" do |cassandra|
      cassandra.vm.hostname = "cassandra-#{i}"
      cassandra.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = "1"
      end
      cassandra.vm.network :private_network, ip: "192.168.10.#{KAFKA + 1 + i }", auto_config: true

      if i == CASSANDRA

        cassandra.vm.provision :ansible do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.limit = "network"
          ansible.playbook = "ansible/network.yml"
          ansible.inventory_path = "ansible/inventories/vbox"
          ansible.raw_arguments  = [
            "-vv"
          ]
        end

        cassandra.vm.provision :ansible do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.limit = "cassandra"
          ansible.playbook = "ansible/cluster.yml"
          ansible.inventory_path = "ansible/inventories/vbox"
          ansible.raw_arguments  = [
            "-vv"
          ]
        end
      end
    end
  end

  (HADDOP).downto(1).each do |i|
    config.vm.define "hadoop-#{i}" do |hadoop|
      hadoop.vm.hostname = "hadoop-#{i}"
      hadoop.vm.provider "virtualbox" do |vb|
        vb.memory = "4096"
        vb.cpus = "2"
      end
      hadoop.vm.network :private_network, ip: "192.168.10.#{KAFKA + CASSANDRA + 1 + i}", auto_config: true

      if i == 1

        hadoop.vm.provision :ansible do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.limit = "network"
          ansible.playbook = "ansible/network.yml"
          ansible.inventory_path = "ansible/inventories/vbox"
          ansible.raw_arguments  = [
            "-vv"
          ]
        end

        hadoop.vm.provision :ansible do |ansible|
          ansible.compatibility_mode = "2.0"
          ansible.limit = "hadoop-master,hadoop-slave"
          ansible.playbook = "ansible/cluster.yml"
          ansible.inventory_path = "ansible/inventories/vbox"
          ansible.raw_arguments  = [
            "-vv"
          ]
        end
      end
    end
  end
end
