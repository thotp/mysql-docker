#!/bin/bash

HOST_BIND_ADDRESS=127.0.0.1

MYSQL_USER=mysql
MYSQL_GROUP=mysql

CONFIG_DIR=/mnt/db/mysql
DATA_DIR=/mnt/db/mysql/data
LOG_DIR=/mnt/db/mysql/log

MY_CNF="${CONFIG_DIR}/my.cnf"

MYSQL_USER_ID=$(echo "${MYSQL_USER}" | xargs id -u)
MYSQL_GROUP_ID=$(echo "${MYSQL_GROUP}" | xargs getent group | cut -d: -f3)

docker run -d --restart=unless-stopped --name=mysql \
	-p ${HOST_BIND_ADDRESS}:3306:3306 \
	-v ${MY_CNF}:/etc/my.cnf:ro \
	-v ${DATA_DIR}:/var/lib/mysql \
	-v ${LOG_DIR}:/var/log/mysql/ \
	-u ${MYSQL_USER_ID}:${MYSQL_GROUP_ID} \
	thotp/mysql-server:8.0.23
