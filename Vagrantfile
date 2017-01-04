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
echo \"192.168.10.8 analytics-1 analytics-1\" >> /etc/hosts
echo \"192.168.10.9 analytics-2 analytics-2\" >> /etc/hosts
echo \"192.168.10.10 analytics-3 analytics-3\" >> /etc/hosts
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.box = "markush81/centos7-vbox-guestadditions"
  config.vm.box_check_update = false

  config.vm.synced_folder "pkgs", "/vagrant/pkgs", create: true
  config.vm.synced_folder "spark", "/home/vagrant/spark", create: true


  config.vm.provider "virtualbox" do |vb|
     vb.memory = "1024"
  end

  config.vm.provision :shell, inline: $hosts
  config.vm.provision :shell, inline: "ifup eth1", run: "always"
  config.vm.provision :shell, path: "files/init-java.sh"
  
  (1..3).each do |i|
    config.vm.define "zookeeper-#{i}" do |kafka|
      kafka.vm.hostname = "zookeeper-#{i}"
      kafka.vm.network :private_network, ip: "192.168.10.#{1+i}", auto_config: true
      kafka.vm.provision :shell, path: "files/init-zookeeper.sh", args: ["#{i}", "192.168.10.#{1+i}"]
    end
  end
  
  (1..3).each do |i|
    config.vm.define "kafka-#{i}" do |kafka|
      kafka.vm.hostname = "kafka-#{i}"
      kafka.vm.network :private_network, ip: "192.168.10.#{4+i}", auto_config: true
      kafka.vm.provision :shell, path: "files/init-kafka.sh", args: ["#{i}", "192.168.10.#{4+i}"]
    end
  end
  
  (1..3).each do |i|
    config.vm.define "analytics-#{i}" do |analytics|
      analytics.vm.hostname = "analytics-#{i}"
      analytics.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
      end
      analytics.vm.network :private_network, ip: "192.168.10.#{7+i}", auto_config: true
      analytics.vm.provision :shell, path: "files/init-cassandra.sh", args: ["#{i}", "192.168.10.#{7+i}"]
      analytics.vm.provision :shell, path: "files/init-spark.sh", args: ["#{i}", "192.168.10.#{7+i}"]      
    end
  end

end
