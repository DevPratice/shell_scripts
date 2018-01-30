#!/bin/bash


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
	if [ -f /opt/tomcat-connectors-1.2.42-src.tar.gz ]; then
		Stat SKIP
	else
		wget http://redrockdigimark.com/apachemirror/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz -O /opt/tomcat-connectors-1.2.42-src.tar.gz &>/dev/null
		Stat $?
	fi
	Print "Extracting Mod_JK Package"
	if [ -d /opt/tomcat-connectors-1.2.42-src ]; then 
		Stat SKIP 
	else
		cd /opt
		tar xf /opt/tomcat-connectors-1.2.42-src.tar.gz
		Stat $?
	fi

	Print "Compiling Mod_JK"
	if [ -f /etc/httpd/modules/mod_jk.so ] ; then 
		Stat SKIP 
	else
		cd /opt/tomcat-connectors-1.2.42-src/native
		./configure --with-apxs=/usr/bin/apxs &>/dev/null && make &>/dev/null && make install &>/dev/null
		Stat $?
	fi


	#Print "Starting Web Server"

}

APP_F() {
	echo "Installing APP Server"
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
