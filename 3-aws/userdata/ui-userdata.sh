#!/bin/bash

repository_url=$1
repo_name=$2
app_port=$3
api_url=$4
user=$5

user_home="/home/$user"
command="$user_home/.command.sh"
nvm_path="$user_home/.nvm/nvm.sh"

exec_as_user() {
  echo "$1" >$command
  sudo su - $user -c "$command"
}

prepare() {
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
  exec_as_user "git clone '$repository_url'"
}

install_nvm() {
  exec_as_user "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
  source $nvm_path
  nvm --version"
  export NVM_DIR="$user_home/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

install_app_requirements() {
  cd $user_home/$repo_name
  node_version=$(cat .node-version)
  message "NodeJs $node_version"

  nvm install $node_version
  node -v

  npm install

  npm install pm2 -g
}

app_pre_setup() {
  echo "APP_PORT=$app_port
API_URL=$api_url" | sudo tee .env
}

start_app() {
  exec_as_user "source $nvm_path
  cd $user_home/$repo_name
  pm2 start ./deployment/ecosystem.config.js --env production --update-env
  pm2 status"
}

set_startup() {
  exec_as_user "source $nvm_path
  pm2 save
  sudo pm2 startup
  sudo chown $user:$user /home/$user/.pm2/rpc.sock /home/$user/.pm2/pub.sock"
}

cleanup() {
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
  cleanup
}

main
