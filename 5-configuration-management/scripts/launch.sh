#! /bin/bash

user_home="/home/$user"

function prepare(){
    echo UPDATING:
    apt-get update && echo "Successful update" || echo "Fail"
    # echo INSTALLING AWSCLI:
    # apt-get install awscli -y && echo "Successful aws" || echo "Fail"
}

function install_docker(){
    echo INSTALLING APT-TRANSPORT-HTTPS:
    apt-get update
    apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y  && echo "Successful https" || echo "Fail"
    echo DOWNLOADING DOCKER:
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -  && echo "Successful docker" || echo "Fail"
    echo ADDING STABLE REPOSITORY:
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"  && echo "Successful docker repository" || echo "Fail"
    echo DOCKER POLICY:
    apt-get update
    echo INSTALLING DOCKER-CE:
    apt-get install docker-ce docker-ce-cli -y  && echo "Successful docker ce" || echo "Fail"
    usermod -aG docker $user && echo "Successful docker all" || echo "Fail"
}

function install_docker_compose(){
    echo INSTALLING DOCKER COMPOSE:
    curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && echo "Successful" || echo "Fail"
    chmod +x /usr/local/bin/docker-compose && echo "Successful docker compose" || echo "Fail"
}

function install_ansible() {
    apt update
    apt install software-properties-common
    apt-add-repository --yes --update ppa:ansible/ansible
    apt install ansible
}

function compose() {
  cp $compose_file_path $user_home
  cd $user_home
  docker-compose up -d
}

function main(){
    prepare
    install_docker
    install_docker_compose
    install_ansible
    compose
}

main
