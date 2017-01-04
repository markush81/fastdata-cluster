#!/bin/sh

SPARK_DOWNLOAD="http://ftp-stud.hs-esslingen.de/pub/Mirrors/ftp.apache.org/dist/spark/spark-2.1.0/spark-2.1.0-bin-hadoop2.7.tgz"

NODE=$1
IP=$2

SPARK_TGZ=`echo $SPARK_DOWNLOAD | awk '{split($0,a,"/"); print a[10]}'`

if ! [ -x "$(command -v spark-submit)" ]; then
	cd /vagrant/pkgs

	if ! [ -f $SPARK_TGZ ]; then
		wget -q $SPARK_DOWNLOAD
	fi

	cd /opt
	rm -rf spark*

	tar xzf /vagrant/pkgs/$SPARK_TGZ
	ln -sf spark-* spark

	sed -i -e 's/#.*SPARK_MASTER_HOST.*$/SPARK_MASTER_HOST=192.168.10.8/g' /opt/spark/conf/spark-env.sh.template
	sed -i -e 's/#.*SPARK_LOCAL_IP.*$/SPARK_LOCAL_IP='$IP'/g' /opt/spark/conf/spark-env.sh.template
	mv /opt/spark/conf/spark-env.sh.template /opt/spark/conf/spark-env.sh
	sed -i -e 's/localhost/'$IP'/g' /opt/spark/conf/slaves.template

	cp /vagrant/files/spark-slave.service /etc/systemd/system
	chmod 664 /etc/systemd/system/spark-slave.service
	systemctl daemon-reload
	systemctl enable spark-slave

	if [ $NODE -eq 1 ]; then
		cp /vagrant/files/spark.service /etc/systemd/system
		chmod 664 /etc/systemd/system/spark.service
		sed -i -e 's/After=.*$/After=spark/g' /etc/systemd/system/spark-slave.service
	
		systemctl daemon-reload
		systemctl enable spark		
	fi
	
	echo "PATH=$PATH:/opt/spark/bin" > /etc/profile.d/fastdata.sh
fi

sed -i -e '/127.0.0.1.*analytics-'$NODE'/d' /etc/hosts

if [ $NODE -eq 1 ]; then
	systemctl start spark
fi
systemctl start spark-slave