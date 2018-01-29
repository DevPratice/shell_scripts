#!/bin/bash


##### Functions
WEB_F() {
	echo "Installing Web Server" 
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

read -p 'Which Service you would like to install[WEB|APP|DB|ALL] : ' SETUP
if [ -z "$SETUP" ]; then 
	SETUP=ALL
fi


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
