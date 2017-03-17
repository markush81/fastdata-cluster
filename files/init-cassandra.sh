#!/bin/sh

CASSANDRA_DOWNLOAD="ftp://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.apache.org/dist/cassandra/3.10/apache-cassandra-3.10-bin.tar.gz"
NODE=$1
IP=$2

CASSSANDRA_TGZ=`echo $CASSANDRA_DOWNLOAD | awk '{split($0,a,"/"); print a[10]}'`

if ! [ -x "$(command -v kafka-server-start.sh)" ]; then
	cd /vagrant/pkgs

	if ! [ -f $CASSSANDRA_TGZ ]; then
		wget -q $CASSANDRA_DOWNLOAD
	fi

	cd /opt
	rm -rf cassandra*

	tar xzf /vagrant/pkgs/$CASSSANDRA_TGZ
	ln -sf apache-cassandra-* cassandra

	cp /vagrant/files/cassandra /opt/cassandra
	chmod +x /opt/cassandra/cassandra
	cp /vagrant/files/cassandra.service /etc/systemd/system
	chmod 664 /etc/systemd/system/cassandra.service
	
	systemctl daemon-reload
	systemctl enable cassandra
  
	rm -rf /var/cassandra/log
	mkdir -p /var/cassandra/log

	sed -i -e 's/cluster_name.*$/cluster_name: 'analytics'/g' /opt/cassandra/conf/cassandra.yaml
	sed -i -e 's/.*seeds.*127.*$/          - seeds: "192.168.10.8, 192.168.10.10"/g' /opt/cassandra/conf/cassandra.yaml
	sed -i -e 's/listen_address:.*$/listen_address: '$IP'/g' /opt/cassandra/conf/cassandra.yaml
	sed -i -e 's/rpc_address:.*$/rpc_address: 0.0.0.0/g' /opt/cassandra/conf/cassandra.yaml
	sed -i -e 's/^.*broadcast_rpc_address:.*$/broadcast_rpc_address: '$IP'/g' /opt/cassandra/conf/cassandra.yaml
	sed -i -e 's/endpoint_snitch:.*$/endpoint_snitch: GossipingPropertyFileSnitch/g' /opt/cassandra/conf/cassandra.yaml

	systemctl enable cassandra
fi

sed -i -e '/127.0.0.1.*analytics-'$NODE'/d' /etc/hosts

systemctl start cassandra