#!/usr/bin/env bash

mysql_root_password="$1"

mysql_app_user=$2
mysql_app_password="$3"
mysql_app_db_name=$4
mysql_db_port=3306

command=".my.sql"

installed() {
  return $(dpkg-query -W -f '${Status}\n' "$1" 2>&1|awk '/ok installed/{print 0; exit}{print 1}')
}

message() {
	echo -e "\033[1m==> $1\033[0m"
}

step() {
  message "STEP: $1"
}

prepare() {
  step "Preparing"
  sudo apt update

	touch $command
  chmod 600 $command

  echo "set showmode
set autoindent
set tabstop=2
set expandtab
syntax on
set number" | sudo tee /etc/vim/vimrc.local
}

install_mysql() {
  step "Installing MySQL"
  sudo apt install mysql-server -y
}

mysql_query() {
  echo "$1" >$command
  sudo mysql <$command
  return $?
}

secure_mysql() {
  step "Securing MySQL"
  mysql_query "DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
}

set_up_mysql() {
  step "DB Setup"

  config_file="/etc/mysql/mysql.conf.d/mysqld.cnf"

  mysql_query "CREATE DATABASE IF NOT EXISTS $mysql_app_db_name;"
  mysql_query "GRANT ALL PRIVILEGES ON $mysql_app_db_name.* TO '$mysql_app_user'@'localhost' IDENTIFIED BY '$mysql_app_password';"
  mysql_query "GRANT ALL PRIVILEGES ON $mysql_app_db_name.* TO '$mysql_app_user'@'%' IDENTIFIED BY '$mysql_app_password';"

  sudo sed -i 's/skip-external-locking/#skip-external-locking/g' $config_file
  sudo sed -i 's/bind-address\s*=\s*127\.0\.0\.1/bind-address = 0.0.0.0/g' $config_file
}

set_root_user_mysql() {
  step "Setting root user"
  mysql_query "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$mysql_root_password';
  FLUSH PRIVILEGES;"
}

finish_set_up_mysql() {
  step "Finishing MySQL setup"
  sudo service mysql restart
}

set_up_firewall() {
  step "Configuring Firewall (ufw)"
  sudo ufw allow ssh
  sudo ufw allow $mysql_db_port/tcp
  sudo ufw --force enable
}

cleanup() {
  step "Cleaning up"
	rm -f $command
}

main() {
  mysql_package=mysql-server

  prepare

  if ! installed $mysql_package; then
     install_mysql
  fi

	#message "$mysql_package alredy installed"
  secure_mysql
	set_up_mysql
  set_root_user_mysql
  finish_set_up_mysql
  set_up_firewall
  cleanup
}

main
