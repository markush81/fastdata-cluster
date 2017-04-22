#!/bin/sh

HADOOP_DOWNLOAD="http://apache.mirrors.spacedump.net/hadoop/common/hadoop-2.8.0/hadoop-2.8.0.tar.gz"
NODE=$1
IP=$2

HADOOP_TGZ=`echo $HADOOP_DOWNLOAD | awk '{split($0,a,"/"); print a[7]}'`

if ! [ -x "$(command -v yarn)" ]; then
	cd /vagrant/pkgs

	if ! [ -f $HADOOP_TGZ ]; then
		wget -q $HADOOP_DOWNLOAD
	fi

	cd /opt
	sudo rm -rf hadoop*

	sudo tar xzf /vagrant/pkgs/$HADOOP_TGZ
	sudo ln -sf hadoop-* hadoop
	sudo chown vagrant:vagrant -R /opt/hadoop*

	if [ $NODE -eq 1 ]; then
		sed -i -e 's/localhost/analytics-1/g' /opt/hadoop/etc/hadoop/slaves
		echo 'analytics-2' >> /opt/hadoop/etc/hadoop/slaves
		echo 'analytics-3' >> /opt/hadoop/etc/hadoop/slaves
		
		sudo cp /vagrant/files/yarn.service /etc/systemd/system
		sudo chmod 664 /etc/systemd/system/yarn.service
		
		sudo cp /vagrant/files/hadoop.service /etc/systemd/system
		sudo chmod 664 /etc/systemd/system/hadoop.service
	
		sudo systemctl daemon-reload
		sudo systemctl enable hadoop
		sudo systemctl enable yarn
		
		ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
		cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
		echo "Host *" >> ~/.ssh/config
		echo "StrictHostKeyChecking no" >> ~/.ssh/config
		echo "UserKnownHostsFile=/dev/null" >> ~/.ssh/config	
		chmod -w ~/.ssh/config
		
		cd /vagrant/pkgs
		if ! [ -f "sshpass-1.06-1.el7.x86_64.rpm" ]; then
			wget -q  http://dl.fedoraproject.org/pub/epel/7/x86_64/s/sshpass-1.06-1.el7.x86_64.rpm
		fi
		sudo rpm -i sshpass-1.06-1.el7.x86_64.rpm

		sshpass -p vagrant ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@analytics-2 || true
		sshpass -p vagrant ssh-copy-id -i ~/.ssh/id_rsa.pub vagrant@analytics-3 || true
	else
		sudo sed -i -e 's/PasswordAuthentication no$/PasswordAuthentication yes/g' /etc/ssh/sshd_config
		sudo systemctl restart sshd.service
	fi
	
	cp /vagrant/files/yarn-site.xml /opt/hadoop/etc/hadoop/yarn-site.xml
	sed -i -e 's/NODEMANAGERIP/'$IP'/g' /opt/hadoop/etc/hadoop/yarn-site.xml
  
	cp /vagrant/files/core-site.xml /opt/hadoop/etc/hadoop/core-site.xml
  
	sed -i -e 's/PATH=.*$/&:\/opt\/hadoop\/bin:\/opt\/hadoop\/sbin/g' ~/.bash_profile

	echo "export HADOOP_PREFIX=/opt/hadoop" >> ~/.bash_profile
	echo "export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop" >> ~/.bash_profile
fi

if [ $NODE -eq 1 ]; then
	/opt/hadoop/bin/hdfs namenode -format
	#sudo systemctl start hadoop
	/opt/hadoop/sbin/start-dfs.sh
	sudo systemctl start yarn
fi

