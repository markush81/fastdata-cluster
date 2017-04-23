#!/bin/sh

FLINK_DOWNLOAD="http://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.apache.org/dist/flink/flink-1.2.0/flink-1.2.0-bin-hadoop27-scala_2.11.tgz"

NODE=$1
IP=$2

FLINK_TGZ=`echo $FLINK_DOWNLOAD | awk '{split($0,a,"/"); print a[10]}'`

if ! [ -x "$(command -v flink)" ]; then
	cd /vagrant/pkgs

	if ! [ -f $FLINK_TGZ ]; then
		wget -q $FLINK_DOWNLOAD
	fi

	cd /opt
	sudo rm -rf flink*

	sudo tar xzf /vagrant/pkgs/$FLINK_TGZ
	sudo ln -sf flink-* flink
	sudo chown vagrant:vagrant -R *flink*
	
	sed -i -e 's/PATH=.*$/&:\/opt\/flink\/bin/g' ~/.bash_profile
	
	sudo cp /vagrant/files/flink.service /etc/systemd/system
	sudo chmod 664 /etc/systemd/system/flink.service

	sudo systemctl daemon-reload
	sudo systemctl enable flink
	
	#sudo systemctl start flink
	/opt/flink/bin/yarn-session.sh -n 3 -jm 768 -tm 768 -s 2 -d
fi