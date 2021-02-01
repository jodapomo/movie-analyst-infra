#!/bin/bash

user_home="/home/$user"
command="$user_home/.command.sh"
nvm_path="$user_home/.nvm/nvm.sh"

cd $user_home

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

  nvm install $node_version
  node -v

  npm install

  npm install -g pm2
}

app_pre_setup() {
  echo "API_PORT=$api_port
MYSQL_HOST=$mysql_host
MYSQL_PORT=$mysql_port
MYSQL_USER=$mysql_user
MYSQL_PASSWORD=$mysql_password
MYSQL_DB_NAME=$mysql_db_name" | sudo tee .env

  node migration.js up
}

start_app() {
  exec_as_user "source $nvm_path
  cd $user_home/$repo_name
  pm2 start ./deployment/ecosystem.config.js --env production --update-env
  pm2 status"
}

set_startup() {
  exec_as_user "source $nvm_path
  comm=$(pm2 startup)
  echo '====> COMM: \$comm'
  if [[ \$comm =~ \"sudo (.*)\" ]]
  then
    sudo bash -c \"\${BASH_REMATCH[1]}\"
  fi
  pm2 save
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
