ENV["LC_ALL"] = "en_US.UTF-8"

$hosts = <<SCRIPT
timedatectl set-timezone Europe/Berlin
echo \"127.0.0.1 localhost localhost\" > /etc/hosts
echo \"192.168.10.2 zookeeper-1 zookeeper-1\" >> /etc/hosts
echo \"192.168.10.3 zookeeper-2 zookeeper-2\" >> /etc/hosts
echo \"192.168.10.4 zookeeper-3 zookeeper-3\" >> /etc/hosts
echo \"192.168.10.5 kafka-1 kafka-1\" >> /etc/hosts
echo \"192.168.10.6 kafka-2 kafka-2\" >> /etc/hosts
echo \"192.168.10.7 kafka-3 kafka-3\" >> /etc/hosts
echo \"192.168.10.8 cassandra-1 cassandra-1\" >> /etc/hosts
echo \"192.168.10.9 cassandra-2 cassandra-2\" >> /etc/hosts
echo \"192.168.10.10 cassandra-3 cassandra-3\" >> /etc/hosts
echo \"192.168.10.11 analytics-1 analytics-1\" >> /etc/hosts
echo \"192.168.10.12 analytics-2 analytics-2\" >> /etc/hosts
echo \"192.168.10.13 analytics-3 analytics-3\" >> /etc/hosts
SCRIPT



Vagrant.configure("2") do |config|

  config.vm.box = "markush81/centos7-vbox-guestadditions"
  config.vm.box_check_update = false

  config.vm.synced_folder "pkgs", "/vagrant/pkgs", create: true
  config.vm.synced_folder "exchange", "/home/vagrant/exchange", create: true


  config.vm.provision :shell, inline: $hosts
  config.vm.provision :shell, inline: "ifup eth1", run: "always"
  config.vm.provision :shell, path: "files/init-java.sh" 
  
  (1..3).each do |i|
    config.vm.define "zookeeper-#{i}" do |zookeeper|
      zookeeper.vm.hostname = "zookeeper-#{i}"
      zookeeper.vm.provider "virtualbox" do |vb|
        vb.memory = "768"
        vb.cpus = "1"
      end
      zookeeper.vm.network :private_network, ip: "192.168.10.#{1+i}", auto_config: true
      zookeeper.vm.provision :shell, path: "files/init-zookeeper.sh", args: ["#{i}", "192.168.10.#{1+i}"], privileged: false  
    end
  end
  
  (1..3).each do |i|
    config.vm.define "kafka-#{i}" do |kafka|
      kafka.vm.hostname = "kafka-#{i}"
      kafka.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = "1"
      end
      kafka.vm.network :private_network, ip: "192.168.10.#{4+i}", auto_config: true
      kafka.vm.provision :shell, path: "files/init-kafka.sh", args: ["#{i}", "192.168.10.#{4+i}"], privileged: false  
    end
  end
  
  (1..3).each do |i|
    config.vm.define "cassandra-#{i}" do |cassandra|
      cassandra.vm.hostname = "cassandra-#{i}"
      cassandra.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = "1"
      end
      cassandra.vm.network :private_network, ip: "192.168.10.#{7+i}", auto_config: true
      cassandra.vm.provision :shell, path: "files/init-cassandra.sh", args: ["#{i}", "192.168.10.#{7+i}"], privileged: false  
    end
  end
    
  (3).downto(1).each do |i|
    config.vm.define "analytics-#{i}" do |analytics|
      analytics.vm.hostname = "analytics-#{i}"
      analytics.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.cpus = "2"
      end
      analytics.vm.network :private_network, ip: "192.168.10.#{10+i}", auto_config: true
      analytics.vm.provision :shell, path: "files/init-hadoop.sh", args: ["#{i}", "192.168.10.#{10+i}"], privileged: false
      
      if i == 1
        analytics.vm.provision :shell, path: "files/init-spark.sh", args: ["1", "192.168.10.#{10+i}"], privileged: false 
      end
    end
  end
end
