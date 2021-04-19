#!/bin/bash

HOST_BIND_ADDRESS=127.0.0.1
MYSQL_ROOT_PASSWORD=root

MYSQL_USER=mysql
MYSQL_GROUP=mysql

rm -rf /var/lib/mysql /var/log/mysql
mkdir -p /var/lib/mysql /var/log/mysql
chown -R ${MYSQL_USER}:${MYSQL_GROUP} /var/lib/mysql /var/log/mysql

rm -rf /etc/mysql
mkdir -p /etc/mysql

cat >"/etc/mysql/my.cnf"<<EOF
[mysqld]
user=${MYSQL_USER}

bind-address=0.0.0.0
port=3306
max-connections=200

datadir=/var/lib/mysql

log-bin=/var/log/mysql/bin.log
log-error=/var/log/mysql/error.log

general-log=1
general-log-file=/var/log/mysql/general.log

slow-query-log=1
slow-query-log-file=/var/log/mysql/slowquery.log

character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci

default-time-zone='00:00'
EOF

chmod 600 /etc/mysql/my.cnf

#DOCKER_HOST_IP=$(ifconfig docker0 | grep "inet 172." | xargs | cut -d' ' -f2)
#echo "Docker Host IP: ${DOCKER_HOST_IP}"

MYSQL_USER_ID=$(echo "${MYSQL_USER}" | xargs id -u)
MYSQL_GROUP_ID=$(echo "${MYSQL_GROUP}" | xargs getent group | cut -d: -f3)
docker run -it --rm --name=mysql \
	-p ${HOST_BIND_ADDRESS}:3306:3306 \
	-v /etc/mysql/my.cnf:/etc/my.cnf:ro \
	-v /var/lib/mysql/:/var/lib/mysql \
	-v /var/log/mysql/:/var/log/mysql/ \
	-e MYSQL_ONETIME_PASSWORD=yes \
	-e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
	-e MYSQL_ROOT_HOST='%' \
	-u ${MYSQL_USER_ID}:${MYSQL_GROUP_ID} \
	mysql-server:8.0.23
