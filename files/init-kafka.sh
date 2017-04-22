#!/bin/sh

KAFKA_DOWNLOAD="http://mirror.dkd.de/apache/kafka/0.10.2.0/kafka_2.11-0.10.2.0.tgz"
NODE=$1
IP=$2

KAFKA_TGZ=`echo $KAFKA_DOWNLOAD | awk '{split($0,a,"/"); print a[7]}'`

if ! [ -x "$(command -v kafka-server-start.sh)" ]; then
	cd /vagrant/pkgs

	if ! [ -f $KAFKA_TGZ ]; then
		wget -q $KAFKA_DOWNLOAD
	fi

	cd /opt
	sudo rm -rf kafka*

	sudo tar xzf /vagrant/pkgs/$KAFKA_TGZ
	sudo ln -sf kafka_* kafka
	sudo chown vagrant:vagrant -R /opt/kafka*
	
	sudo mkdir -p /var/kafka
	sudo chown vagrant:vagrant -R /var/kafka

	cp /vagrant/files/kafka /opt/kafka
	chmod +x /opt/kafka/kafka
	
	sudo cp /vagrant/files/kafka.service /etc/systemd/system
	sudo chmod 664 /etc/systemd/system/kafka.service
	
	sudo systemctl daemon-reload
	sudo systemctl enable kafka
  
	sed -i -e 's/broker.id=.*$/broker.id='$NODE'/g' /opt/kafka/config/server.properties
	sed -i -e 's/#listeners.*$/listeners=PLAINTEXT:\/\/0.0.0.0:9092/g' /opt/kafka/config/server.properties
	sed -i -e 's/#advertised.listeners.*$/advertised.listeners=PLAINTEXT:\/\/'$IP':9092/g' /opt/kafka/config/server.properties
	sed -i -e 's/log.dirs=.*$/log.dirs=\/var\/kafka\/logs/g' /opt/kafka/config/server.properties
	sed -i -e 's/zookeeper.connect=.*$/zookeeper.connect=zookeeper-1:2181,zookeeper-2:2181,zookeeper-3:2181/g' /opt/kafka/config/server.properties
	
	sed -i -e 's/PATH=.*$/PATH=$PATH:\/opt\/kafka\/bin/g' ~/.bash_profile	
fi

sudo systemctl start kafka