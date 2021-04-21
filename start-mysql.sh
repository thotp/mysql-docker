#!/bin/bash

MYSQL_USER=mysql
MYSQL_GROUP=mysql

CONFIG_DIR=/mysql
DATA_DIR=/mysql/data
LOG_DIR=/var/log/mysql

MY_CNF="${CONFIG_DIR}/my.cnf"

MYSQL_USER_ID=$(echo "${MYSQL_USER}" | xargs id -u)
MYSQL_GROUP_ID=$(echo "${MYSQL_GROUP}" | xargs getent group | cut -d: -f3)

docker run -d --restart=unless-stopped --name=mysql-server \
	--network=host \
	-v ${MY_CNF}:/etc/my.cnf:ro \
	-v ${DATA_DIR}:/var/lib/mysql \
	-v ${LOG_DIR}:/var/log/mysql \
	-u ${MYSQL_USER_ID}:${MYSQL_GROUP_ID} \
	thotp/mysql-server:8.0.23
