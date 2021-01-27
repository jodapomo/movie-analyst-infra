#!/usr/bin/env bash

repository_url=$1
repo_name=$2
app_port=$3
api_url=$4
user=$5

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
  echo "APP_PORT=$app_port
API_URL=$api_url" | sudo tee .env
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

install_nginx() {
  step "Installing Nginx"
  sudo apt install nginx -y
}

set_up_nginx() {
  step "Configuring Nginx"
  config_file="reverse-proxy.conf"
  sudo unlink /etc/nginx/sites-enabled/default
  cp $user_home/$repo_name/deployment/$config_file /etc/nginx/sites-available/
  sudo sed -i "s;\[API_URL\];$api_url;g" /etc/nginx/sites-available/$config_file
  sudo sed -i "s;\[APP_PORT\];$app_port;g" /etc/nginx/sites-available/$config_file
  sudo ln -s /etc/nginx/sites-available/$config_file /etc/nginx/sites-enabled/$config_file
  sudo service nginx restart
}

set_up_firewall() {
  step "Configuring Firewall (ufw)"
  sudo ufw allow ssh
  sudo ufw allow 'Nginx Full'
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
  install_nginx
  set_up_nginx
  set_up_firewall
  cleanup
}

main
