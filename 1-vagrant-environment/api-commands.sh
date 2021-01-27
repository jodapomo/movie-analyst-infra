#!/usr/bin/env bash

sudo apt update
git clone https://github.com/jodapomo/movie-analyst-api

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
source .bashrc

cd movie-analyst-api
nvm install 12.18.4 <-- use .node-version file
npm install pm2 -g
npm install

node migration.js up

pm2 start ./deployment/ecosystem.config.js --env production --update-env

pm2 startup

pm2 save

sudo env PATH=$PATH:/home/vagrant/.nvm/versions/node/v12.18.4/bin /home/vagrant/.nvm/versions/node/v12.18.4/lib/node_modules/pm2/bin/pm2 startup systemd -u vagrant --hp /home/vagrant
