ENV["LC_ALL"] = "en_US.UTF-8"

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

  ZOOKEEPER = 3
  
  (1..ZOOKEEPER).each do |i|
    config.vm.define "zookeeper-#{i}" do |zookeeper|
      zookeeper.vm.hostname = "zookeeper-#{i}"
      zookeeper.vm.provider "virtualbox" do |vb|
        vb.memory = "512"
        vb.cpus = "1"
      end
      zookeeper.vm.network :private_network, ip: "192.168.10.#{1+i}", auto_config: true
      
      if i == ZOOKEEPER
        zookeeper.vm.provision :ansible do |ansible|
          # Disable default limit to connect to all the machines
          ansible.limit = "all"
          ansible.playbook = "ansible/zookeeper.yml"
          ansible.inventory_path = "ansible/inventories/vbox"
          ansible.raw_arguments  = [
            "-vv"
          ]
        end
      end
    end
  end
  
  #(1..3).each do |i|
  #  config.vm.define "kafka-#{i}" do |kafka|
  #    kafka.vm.hostname = "kafka-#{i}"
  #    kafka.vm.provider "virtualbox" do |vb|
  #      vb.memory = "1024"
  #      vb.cpus = "1"
  #    end
  #    kafka.vm.network :private_network, ip: "192.168.10.#{4+i}", auto_config: true
  #    kafka.vm.provision :shell, path: "files/init-kafka.sh", args: ["#{i}", "192.168.10.#{4+i}"], privileged: false  
  #  end
  #end
  
  #(1..3).each do |i|
  #  config.vm.define "cassandra-#{i}" do |cassandra|
  #    cassandra.vm.hostname = "cassandra-#{i}"
  #    cassandra.vm.provider "virtualbox" do |vb|
  #      vb.memory = "1024"
  #      vb.cpus = "1"
  #    end
  #    cassandra.vm.network :private_network, ip: "192.168.10.#{7+i}", auto_config: true
  #    cassandra.vm.provision :shell, path: "files/init-cassandra.sh", args: ["#{i}", "192.168.10.#{7+i}"], privileged: false  
  #  end
  #end
    
  #(3).downto(1).each do |i|
  #  config.vm.define "analytics-#{i}" do |analytics|
  #    analytics.vm.hostname = "analytics-#{i}"
  #    if i == 1
  #      analytics.vm.provider "virtualbox" do |vb|
  #        vb.memory = "3584"
  #        vb.cpus = "2"
  #      end
  #    else 
  #      analytics.vm.provider "virtualbox" do |vb|
  #        vb.memory = "3072"
  #        vb.cpus = "2"
  #      end
  #    end
  #    analytics.vm.network :private_network, ip: "192.168.10.#{10+i}", auto_config: true
  #    analytics.vm.provision :shell, path: "files/init-hadoop.sh", args: ["#{i}", "192.168.10.#{10+i}"], privileged: false
  #    
  #    if i == 1
  #      analytics.vm.provision :shell, path: "files/init-spark.sh", args: ["1", "192.168.10.#{10+i}"], privileged: false 
  #      analytics.vm.provision :shell, path: "files/init-flink.sh", args: ["1", "192.168.10.#{10+i}"], privileged: false 
  #    end
  #  end
  #end
end
