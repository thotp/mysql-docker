#!/bin/bash
# Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

# This script will simply use sed to replace placeholder variables in the
# files in template/ with version-specific variants.

set -e

source VERSION

REPO=https://repo.mysql.com; [ -n "$1" ] && REPO=$1
MAJOR_VERSIONS=("${!MYSQL_CLUSTER_VERSIONS[@]}"); [ -n "$2" ] && MAJOR_VERSIONS=("${@:2}")

for MAJOR_VERSION in "${MAJOR_VERSIONS[@]}"; do
  # Dockerfile
  sed 's#%%MYSQL_CLUSTER_PACKAGE%%#'"mysql-cluster-community-server-minimal-${MYSQL_CLUSTER_VERSIONS[${MAJOR_VERSION}]}"'#g' template/Dockerfile > tmpFile
  sed -i 's#%%MYSQL_SHELL_PACKAGE%%#'"mysql-shell-${MYSQL_SHELL_VERSIONS[${MAJOR_VERSION}]}"'#g' tmpFile
  sed -i 's#%%REPO%%#'"${REPO}"'#g' tmpFile
  REPO_VERSION=${MAJOR_VERSION//\./}
  sed -i 's#%%REPO_VERSION%%#'"${REPO_VERSION}"'#g' tmpFile
  mv tmpFile ${MAJOR_VERSION}/Dockerfile

  # control.rb
  sed 's#%%MYSQL_CLUSTER_PACKAGE_VERSION%%#'"${MYSQL_CLUSTER_VERSIONS[${MAJOR_VERSION}]}"'#g' template/control.rb > tmpFile
  sed -i 's#%%MYSQL_SHELL_PACKAGE_VERSION%%#'"${MYSQL_SHELL_VERSIONS[${MAJOR_VERSION}]}"'#g' tmpFile
  if [ ! -d "${MAJOR_VERSION}/inspec" ]; then
    mkdir "${MAJOR_VERSION}/inspec"
  fi
  mv tmpFile "${MAJOR_VERSION}/inspec/control.rb"

  # Entrypoint
  sed 's#%%PASSWORDSET%%#'"${PASSWORDSET[${MAJOR_VERSION}]}"'#g' template/docker-entrypoint.sh > tmpFile
  sed -i 's#%%SERVER_VERSION_FULL%%#'"${SERVER_VERSION_FULL[${MAJOR_VERSION}]}"'#g' tmpFile
  mv tmpFile ${MAJOR_VERSION}/docker-entrypoint.sh
  chmod +x ${MAJOR_VERSION}/docker-entrypoint.sh

  # Healthcheck
  cp template/healthcheck.sh ${MAJOR_VERSION}/
  chmod +x ${MAJOR_VERSION}/healthcheck.sh

  # Config
  cp -r template/cnf ${MAJOR_VERSION}/
done
