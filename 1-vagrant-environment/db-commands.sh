#!/usr/bin/env bash

sudo apt update
sudo apt install mysql-server
sudo mysql_secure_installation (si a todo)

sudo mysql
SELECT user,authentication_string,plugin,host FROM mysql.user;

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '_2Gj-wTVYgBJk?56';

CREATE DATABASE movie_db;

GRANT ALL PRIVILEGES ON movie_db.* TO 'movie'@'localhost' IDENTIFIED BY '_2Gj-wTVYgBJk?56';
GRANT ALL PRIVILEGES ON movie_db.* TO 'movie'@'%' IDENTIFIED BY '_2Gj-wTVYgBJk?56';

sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf

sudo service mysql restart
