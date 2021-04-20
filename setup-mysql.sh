#!/bin/bash

HOST_BIND_ADDRESS=127.0.0.1
MYSQL_ROOT_PASSWORD=root

MYSQL_USER=mysql
MYSQL_GROUP=mysql

CONFIG_DIR=/mnt/db/mysql
DATA_DIR=/mnt/db/mysql/data
LOG_DIR=/mnt/db/mysql/log

rm -rf ${DATA_DIR} ${LOG_DIR}
mkdir -p ${DATA_DIR} ${LOG_DIR}
chown -R ${MYSQL_USER}:${MYSQL_GROUP} ${DATA_DIR} ${LOG_DIR}

MY_CNF="${CONFIG_DIR}/my.cnf"

cat >"${MY_CNF}"<<EOF
[mysqld]
user=${MYSQL_USER}

bind-address=0.0.0.0
port=3306

max-connections=200
default-time-zone='+00:00'

datadir=/var/lib/mysql

character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci

log-bin=/var/log/mysql/bin.log
log-error=/var/log/mysql/error.log
general-log=1
general-log-file=/var/log/mysql/general.log
slow-query-log=1
slow-query-log-file=/var/log/mysql/slowquery.log
EOF

MYSQL_USER_ID=$(echo "${MYSQL_USER}" | xargs id -u)
MYSQL_GROUP_ID=$(echo "${MYSQL_GROUP}" | xargs getent group | cut -d: -f3)

docker run -d --restart=unless-stopped --name=mysql \
	-p ${HOST_BIND_ADDRESS}:3306:3306 \
	-v ${MY_CNF}:/etc/my.cnf:ro \
	-v ${DATA_DIR}:/var/lib/mysql \
	-v ${LOG_DIR}:/var/log/mysql/ \
	-e MYSQL_ONETIME_PASSWORD=yes \
	-e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
	-e MYSQL_ROOT_HOST='%' \
	-u ${MYSQL_USER_ID}:${MYSQL_GROUP_ID} \
	thotp/mysql-server:8.0.23
