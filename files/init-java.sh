#!/bin/sh

if ! [ -x "$(command -v java)" ]; then
	cd /vagrant/pkgs
	
	if ! [ -f "jdk-8u111-linux-x64.rpm" ]; then
		wget -q  --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-linux-x64.rpm
	fi
	rpm -i jdk-8u111-linux-x64.rpm
	
	echo "export JAVA_HOME=/usr/java/default" >> /etc/profile.d/java.sh
fi