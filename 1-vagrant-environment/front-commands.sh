#!/usr/bin/env bash

sudo apt update

sudo ufw allow ssh
sudo ufw app list
sudo ufw allow 'Nginx Full'
sudo ufw enable

sudo apt install nginx

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
source .bashrc
nvm install 12.18.4 <-- use .node-version file

git clone https://github.com/jodapomo/movie-analyst-ui

cd movie-analyst-ui

# change pm2 file env vars\

npm install

npm install pm2 -g

pm2 start ./deployment/ecosystem.config.js --env production --update-env

sudo env PATH=$PATH:/home/vagrant/.nvm/versions/node/v12.18.4/bin /home/vagrant/.nvm/versions/node/v12.18.4/lib/node_modules/pm2/bin/pm2 startup systemd -u vagrant --hp /home/vagrant


sudo unlink /etc/nginx/sites-enabled/default

cd etc/nginx/sites-available/

vim reverse-proxy.conf

sudo ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
