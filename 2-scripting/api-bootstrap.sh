#!/usr/bin/env bash

repository_url=$1
repo_name=$2
api_port=$3
mysql_host=$4
mysql_port=$5
mysql_user=$6
mysql_password=$7
mysql_db_name=$8
user=$9

user_home="/home/$user"
command="$user_home/.command.sh"
nvm_path="$user_home/.nvm/nvm.sh"

installed() {
  return $(dpkg-query -W -f '${Status}\n' "$1" 2>&1|awk '/ok installed/{print 0; exit}{print 1}')
}

message() {
	echo -e "\033[1m==> $1\033[0m"
}

step() {
  message "STEP: $1"
}

exec_as_user() {
  echo "$1" >$command
  sudo su - $user -c "$command"
}

prepare() {
  step "Preparing"
  sudo apt update
  touch $command
  chmod 777 $command

  echo "set showmode
set autoindent
set tabstop=2
set expandtab
syntax on
set number" | sudo tee /etc/vim/vimrc.local
}

clone_repo() {
  step "Cloning Repo"
  exec_as_user "git clone '$repository_url'"
}

install_nvm() {
  step "Node Environment"
  exec_as_user "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
  source $nvm_path
  nvm --version"
  export NVM_DIR="$user_home/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

install_app_requirements() {
  step "Installing $repo_name requirements"

  cd $user_home/$repo_name
  node_version=$(cat .node-version)
  message "NodeJs $node_version"

  nvm install $node_version
  node -v

  npm install

  npm install pm2 -g
}

app_pre_setup() {
  step "Pre setup"
  echo "API_PORT=$api_port
MYSQL_HOST=$mysql_host
MYSQL_PORT=$mysql_port
MYSQL_USER=$mysql_user
MYSQL_PASSWORD=$mysql_password
MYSQL_DB_NAME=$mysql_db_name" | sudo tee .env

  node migration.js up
}

start_app() {
  step "Starting the app"
  exec_as_user "source $nvm_path
  cd $user_home/$repo_name
  pm2 start ./deployment/ecosystem.config.js --env production --update-env
  pm2 status"
}

set_startup() {
  step "Configuring startup"
  exec_as_user "source $nvm_path
  pm2 save
  sudo pm2 startup
  sudo chown $user:$user /home/$user/.pm2/rpc.sock /home/$user/.pm2/pub.sock"
}

set_up_firewall() {
  step "Configuring Firewall (ufw)"
  sudo ufw allow ssh
  sudo ufw allow $api_port/tcp
  sudo ufw --force enable
}

cleanup() {
  step "Cleaning up"
	rm -f $command
}

main() {
  prepare
  clone_repo
  install_nvm
  install_app_requirements
  app_pre_setup
  start_app
  set_startup
  set_up_firewall
  cleanup
}

main
