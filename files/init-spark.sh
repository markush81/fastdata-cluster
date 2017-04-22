#!/bin/sh

SPARK_DOWNLOAD="http://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.apache.org/dist/spark/spark-2.1.0/spark-2.1.0-bin-without-hadoop.tgz"

NODE=$1
IP=$2

SPARK_TGZ=`echo $SPARK_DOWNLOAD | awk '{split($0,a,"/"); print a[10]}'`

if ! [ -x "$(command -v spark-submit)" ]; then
	cd /vagrant/pkgs

	if ! [ -f $SPARK_TGZ ]; then
		wget -q $SPARK_DOWNLOAD
	fi

	cd /opt
	sudo rm -rf spark*

	sudo tar xzf /vagrant/pkgs/$SPARK_TGZ
	sudo ln -sf spark-* spark
	sudo chown vagrant:vagrant -R spark*
	
	sed -i -e 's/PATH=.*$/&:\/opt\/spark\/bin/g' ~/.bash_profile
	echo "SPARK_LOCAL_IP='$IP'" >>  ~/.bash_profile
	echo "export SPARK_DIST_CLASSPATH=$(hadoop classpath)" >> ~/.bash_profile
fi