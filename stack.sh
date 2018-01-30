#!/bin/bash


#### Variables
MODJK_URL='http://redrockdigimark.com/apachemirror/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz'
MODJK_TAR_FILE="/opt/$(echo $MODJK_URL | awk -F / '{print $NF}')"
MODJK_DIR=$(echo $MODJK_TAR_FILE | sed -e 's/.tar.gz//' )

TOMCAT_URL='http://redrockdigimark.com/apachemirror/tomcat/tomcat-8/v8.5.27/bin/apache-tomcat-8.5.27.tar.gz'
TOMCAT_TAR_FILE="/opt/$(echo $TOMCAT_URL | awk -F / '{print $NF}')"
TOMCAT_DIR=$(echo $TOMCAT_TAR_FILE | sed -e 's/.tar.gz//')

##### Functions
HEAD_F() {
	echo -e "** \e[35;4m$1\e[0m"	
}

Print() {
	echo -en "	-> $1 - "
}

Stat() {
	if [ $1 == SKIP ]; then 
		echo -e "\e[34mSKIPPING\e[0m"
	elif [ $1 -eq 0 ]; then 
		echo -e "\e[32mSUCCESS\e[0m"
	else
		echo -e "\e[31mFAILURE\e[0m"
		exit 1
	fi
}

WEB_F() {
	HEAD_F "Configuring Web Service"

	Print "Installing Web Server"
	yum install httpd httpd-devel gcc -y &>/dev/null
	Stat $?
	Print "Downloading Mod_JK Package"
	if [ -f $MODJK_TAR_FILE ]; then
		Stat SKIP
	else
		wget $MODJK_URL -O $MODJK_TAR_FILE &>/dev/null
		Stat $?
	fi
	Print "Extracting Mod_JK Package"
	if [ -d $MODJK_DIR ]; then 
		Stat SKIP 
	else
		cd /opt
		tar xf $MODJK_TAR_FILE
		Stat $?
	fi

	Print "Compiling Mod_JK"
	if [ -f /etc/httpd/modules/mod_jk.so ] ; then 
		Stat SKIP 
	else
		cd $MODJK_DIR/native
		./configure --with-apxs=/usr/bin/apxs &>/dev/null && make &>/dev/null && make install &>/dev/null
		Stat $?
	fi
	echo 'worker.list=tomcatA
### Set properties
worker.tomcatA.type=ajp13
worker.tomcatA.host=localhost
worker.tomcatA.port=8009' >/etc/httpd/conf.d/worker.properties

	echo 'LoadModule jk_module modules/mod_jk.so
JkWorkersFile conf.d/worker.properties
JkMount /student tomcatA
JkMount /student/* tomcatA' >/etc/httpd/conf.d/mod_jk.conf

	Print "Starting Web Service"
	systemctl enable httpd &>/dev/null
	systemctl restart httpd &>/dev/null 
	Stat $?
}

APP_F() {
	
}

DB_F() {
	echo "Installing DB Server"
}

ALL_F() {
	WEB_F
	APP_F
	DB_F
}

##### Main Script
if [ "$USER" != root ]; then 
	echo "You should be a root user to perform this script"
	exit 1
fi

if [ -z "$1" ]; then 
	read -p 'Which Service you would like to install[WEB|APP|DB|ALL] : ' SETUP
	if [ -z "$SETUP" ]; then 
		SETUP=ALL
	fi
else
	SETUP=$1
fi

SETUP=$(echo $SETUP | tr [a-z] [A-Z])
case $SETUP in 
	WEB|web) 
		WEB_F
		;;
	APP|app)
		APP_F
		;;
	DB|db)
		DB_F
		;;
	ALL|all)
		ALL_F
		;;
	*) 
		echo "Allowed values are WEB|APP|DB|ALL ... Try Again .."
		exit 1
esac
