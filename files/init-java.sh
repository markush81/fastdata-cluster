#!/bin/sh

if ! [ -x "$(command -v java)" ]; then
	cd /vagrant/pkgs
	
	if ! [ -f "jdk-8u111-linux-x64.rpm" ]; then
		wget -q  --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u111-b14/jdk-8u111-linux-x64.rpm
	fi
	rpm -i jdk-8u111-linux-x64.rpm
fi