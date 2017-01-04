#!/bin/sh

NODE=$1
IP=$2

if ! [ -x "$(command -v cassandra)" ]; then

	touch /etc/yum.repos.d/datastax.repo
	cat <<EOT >> /etc/yum.repos.d/datastax.repo
[datastax] 
name = DataStax Repo for Apache Cassandra
baseurl = http://rpm.datastax.com/datastax-ddc/3.9/
enabled = 1
gpgcheck = 0
EOT
	
	cd /vagrant/pkgs
	if ! [ -f "datastax-ddc*"]; then 
		yum clean all
		yumdownloader datastax-ddc
	fi
	yum install `find datastax-ddc*` -y

	sed -i -e 's/cluster_name.*$/cluster_name: 'analytics'/g' /etc/cassandra/conf/cassandra.yaml
	sed -i -e 's/.*seeds.*127.*$/          - seeds: "192.168.10.8, 192.168.10.10"/g' /etc/cassandra/conf/cassandra.yaml
	sed -i -e 's/listen_address:.*$/listen_address: '$IP'/g' /etc/cassandra/conf/cassandra.yaml
	sed -i -e 's/rpc_address:.*$/rpc_address: 0.0.0.0/g' /etc/cassandra/conf/cassandra.yaml
	sed -i -e 's/^.*broadcast_rpc_address:.*$/broadcast_rpc_address: '$IP'/g' /etc/cassandra/conf/cassandra.yaml
	sed -i -e 's/endpoint_snitch:.*$/endpoint_snitch: GossipingPropertyFileSnitch/g' /etc/cassandra/conf/cassandra.yaml
	rm -f /etc/cassandra/conf/cassandra-topology.properties

	systemctl enable cassandra
fi

sed -i -e '/127.0.0.1.*analytics-'$NODE'/d' /etc/hosts

systemctl start cassandra