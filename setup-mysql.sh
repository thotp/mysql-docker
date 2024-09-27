#!/bin/bash

MYSQL_ROOT_PASSWORD=root

MYSQL_USER=mysql
MYSQL_GROUP=mysql

CONFIG_DIR=/mysql
DATA_DIR=/mysql/data
LOG_DIR=/var/log/mysql

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

#log-bin=/var/log/mysql/bin.log
log-error=/var/log/mysql/error.log
general-log=1
general-log-file=/var/log/mysql/general.log
slow-query-log=1
slow-query-log-file=/var/log/mysql/slowquery.log

# Group Replication
# https://dev.mysql.com/doc/refman/8.0/en/group-replication-configuring-instances.html
#
disabled_storage_engines="MyISAM,BLACKHOLE,FEDERATED,ARCHIVE,MEMORY"

server_id=1
gtid_mode=ON
enforce_gtid_consistency=ON

log_bin=binlog
log_slave_updates=ON
binlog_format=ROW
#master_info_repository=TABLE (deprecated)
#relay_log_info_repository=TABLE (deprecated)
relay_log=pi1-relay-bin
transaction_write_set_extraction=XXHASH64

plugin_load_add='group_replication.so'
group_replication_group_name="cd89fe36-a1ff-11eb-9ec1-0242ac110002"
group_replication_start_on_boot=off
group_replication_local_address="pi1.lan:33061"
group_replication_group_seeds=""
group_replication_bootstrap_group=off
group_replication_recovery_public_key_path="public_key.pem"

# InnoDB Cluster
#
binlog_transaction_dependency_tracking=WRITESET
slave_parallel_type=LOGICAL_CLOCK
slave_preserve_commit_order=ON
EOF

MYSQL_USER_ID=$(echo "${MYSQL_USER}" | xargs id -u)
MYSQL_GROUP_ID=$(echo "${MYSQL_GROUP}" | xargs getent group | cut -d: -f3)

docker run -d --restart=unless-stopped --name=mysql-server \
	--network=host \
	-v ${MY_CNF}:/etc/my.cnf:ro \
	-v ${DATA_DIR}:/var/lib/mysql \
	-v ${LOG_DIR}:/var/log/mysql \
	-e MYSQL_ONETIME_PASSWORD=yes \
	-e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
	-e MYSQL_ROOT_HOST='%' \
	-u ${MYSQL_USER_ID}:${MYSQL_GROUP_ID} \
	thotp/mysql-server:8.0.23
