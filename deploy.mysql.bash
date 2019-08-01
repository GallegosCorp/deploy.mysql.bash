#!/bin/bash
# Script written by William Ford 
# will.ford@gallegoscorp.com
any_key(){
	read -n 1 -s -r -p "Press any key to continue"
	echo
}
set_root_password() {
	echo "SETTING UP ROOT PASSWORD"
	rootPasswd="$(openssl rand -base64 12)"
	secure_mysql
}
#Secure MySQL Database
secure_mysql(){
echo
echo
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "UPDATE mysql.user SET Password=PASSWORD('$rootPasswd') WHERE User='root'"
mysql -e "FLUSH PRIVILEGES;"
database_config
}
database_config(){
	echo "SETTING UP DATABASE"
	sleep 1
	echo "CREATING DATABASE, USER, AND RANDOM PASSWORD"
	echo "WHAT IS YOUR DATABASE USERNAME?"
	read DBUSER
	echo "WHAT IS YOUR DATABASE NAME?"
	read DBNAME
	echo "CREATING RANDOM PASSWORD"
	#create random password
	sqlPassword="$(openssl rand -base64 12)"
	sqlUser=$DBUSER
	#replace "-" with "_" for database username
	mainDB=$DBNAME
	# If /root/.my.cnf exists then it won't ask for root password
	if [ -f /root/.my.cnf ]; then
		mysql -e "CREATE DATABASE ${mainDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
		mysql -e "CREATE USER ${mainDB}@localhost IDENTIFIED BY '${sqlPassword}';"
		mysql -e "GRANT ALL PRIVILEGES ON ${mainDB}.* TO '${mainDB}'@'localhost';"
		mysql -e "FLUSH PRIVILEGES;"
	# If /root/.my.cnf doesn't exist then it'll ask for root password   
	else
		mysql -uroot -p${rootPasswd} -e "CREATE DATABASE ${mainDB} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
		mysql -uroot -p${rootPasswd} -e "CREATE USER ${mainDB}@localhost IDENTIFIED BY '${sqlPassword}';"
		mysql -uroot -p${rootPasswd} -e "GRANT ALL PRIVILEGES ON ${mainDB}.* TO '${mainDB}'@'localhost';"
		mysql -uroot -p${rootPasswd} -e "FLUSH PRIVILEGES;"
	fi
	echo "DATABASES CONFIGURED"
	echo
	echo "PLEASE SAVE THIS INFORMATION, YOU WILL NEED IT"
	echo "**********************************************"
	echo "  SQL USERNAME:" $sqlUser
	echo "  SQL PASSWORD:" $sqlPassword
	echo "  SQL DATABASE:" $mainDB
	echo " ROOT PASSWORD:" $rootPasswd
	echo "**********************************************"
	echo
	echo "MySQL INSTALLATION COMPLETE"
	any_key
}
if [ "$EUID" -ne 0 ]
  then 
	echo "Please run as root"
  else
	apt install mysql-server -y
	set_root_password
 fi