#!/bin/sh

KAFKA_DOWNLOAD="http://mirror.dkd.de/apache/kafka/0.10.1.0/kafka_2.11-0.10.1.0.tgz"

NODE=$1
IP=$2

KAFKA_TGZ=`echo $KAFKA_DOWNLOAD | awk '{split($0,a,"/"); print a[7]}'`

if ! [ -x "$(command -v zookeeper-server-start.sh)" ]; then
	cd /vagrant/pkgs

	if ! [ -f $KAFKA_TGZ ]; then
		wget -q $KAFKA_DOWNLOAD
	fi

	cd /opt
	rm -rf /opt/kafka*

	tar xzf /vagrant/pkgs/$KAFKA_TGZ
	ln -sf kafka_* kafka

	cp /vagrant/files/zookeeper /opt/kafka
	chmod +x /opt/kafka/zookeeper
	cp /vagrant/files/zookeeper.service /etc/systemd/system
	chmod 664 /etc/systemd/system/zookeeper.service

	systemctl daemon-reload
	systemctl enable zookeeper
  
	rm -rf /var/zookeeper/data
	mkdir -p /var/zookeeper/data

	sed -i -e 's/dataDir=.*$/dataDir=\/var\/zookeeper\/data/g' /opt/kafka/config/zookeeper.properties
	echo "server.1=zookeeper-1:2888:3888" >> /opt/kafka/config/zookeeper.properties
	echo "server.2=zookeeper-2:2888:3888" >> /opt/kafka/config/zookeeper.properties
	echo "server.3=zookeeper-3:2888:3888" >> /opt/kafka/config/zookeeper.properties
	echo "tickTime=2000" >> /opt/kafka/config/zookeeper.properties
	echo "initLimit=5" >> /opt/kafka/config/zookeeper.properties
	echo "syncLimit=2" >> /opt/kafka/config/zookeeper.properties
	echo $NODE > /var/zookeeper/data/myid
	
	echo "PATH=$PATH:/opt/kafka/bin" > /etc/profile.d/fastdata.sh
fi

sed -i -e '/127.0.0.1.*zookeeper-'$NODE'/d' /etc/hosts

systemctl start zookeeper