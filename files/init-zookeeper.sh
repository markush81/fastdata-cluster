#!/bin/sh

KAFKA_DOWNLOAD="http://mirror.dkd.de/apache/kafka/0.10.2.0/kafka_2.11-0.10.2.0.tgz"

NODE=$1
IP=$2

KAFKA_TGZ=`echo $KAFKA_DOWNLOAD | awk '{split($0,a,"/"); print a[7]}'`

if ! [ -x "$(command -v zookeeper-server-start.sh)" ]; then
	cd /vagrant/pkgs

	if ! [ -f $KAFKA_TGZ ]; then
		wget -q $KAFKA_DOWNLOAD
	fi

	cd /opt
	sudo rm -rf /opt/zookeeper*

	sudo tar xzf /vagrant/pkgs/$KAFKA_TGZ
	sudo ln -sf kafka_* zookeeper
	sudo chown vagrant:vagrant -R /opt/zookeeper*
	sudo chown vagrant:vagrant -R /opt/kafka*
	
	sudo mkdir -p /var/zookeeper
	sudo chown vagrant:vagrant -R /var/zookeeper
	
	mkdir -p /var/zookeeper/data

	cp /vagrant/files/zookeeper /opt/zookeeper
	chmod +x /opt/zookeeper/zookeeper
	
	sudo cp /vagrant/files/zookeeper.service /etc/systemd/system
	sudo chmod 664 /etc/systemd/system/zookeeper.service

	sudo systemctl daemon-reload
	sudo systemctl enable zookeeper
  
	sed -i -e 's/dataDir=.*$/dataDir=\/var\/zookeeper\/data/g' /opt/zookeeper/config/zookeeper.properties
	echo "server.1=zookeeper-1:2888:3888" >> /opt/zookeeper/config/zookeeper.properties
	echo "server.2=zookeeper-2:2888:3888" >> /opt/zookeeper/config/zookeeper.properties
	echo "server.3=zookeeper-3:2888:3888" >> /opt/zookeeper/config/zookeeper.properties
	echo "tickTime=2000" >> /opt/zookeeper/config/zookeeper.properties
	echo "initLimit=5" >> /opt/zookeeper/config/zookeeper.properties
	echo "syncLimit=2" >> /opt/zookeeper/config/zookeeper.properties
	echo $NODE > /var/zookeeper/data/myid
	
	sed -i -e 's/PATH=.*$/PATH=$PATH:\/opt\/zookeeper\/bin/g' ~/.bash_profile
fi

sudo systemctl start zookeeper