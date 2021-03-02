#!/bin/sh
# This program and the accompanying materials are
# made available under the terms of the Eclipse Public License v2.0 which accompanies
# this distribution, and is available at https://www.eclipse.org/legal/epl-v20.html
# 
# SPDX-License-Identifier: EPL-2.0
# 
# Copyright Contributors to the Zowe Project.

#ZLUX_CONFIG_FILE, WORKSPACE_DIR, and INSTANCE_DIR are for official Zowe environment use.
#If none found, will assume dev environment and consider ~/.zowe as INSTANCE_DIR


if [ -n "${WORKSPACE_DIR}" ]
then
  if [ -e "${WORKSPACE_DIR}/app-server/serverConfig/server.json" ]
  then
    export CONFIG_FILE="${WORKSPACE_DIR}/app-server/serverConfig/server.json"
  else
    cd ../lib
    __UNTAGGED_READ_MODE=V6 $NODE_BIN initInstance.js
    export CONFIG_FILE="${WORKSPACE_DIR}/app-server/serverConfig/server.json"
    cd ../bin
  fi
elif [ -n "${INSTANCE_DIR}" ]
then
  if [ -e "${INSTANCE_DIR}/workspace/app-server/serverConfig/server.json" ]
  then
    export CONFIG_FILE="${INSTANCE_DIR}/workspace/app-server/serverConfig/server.json"
  else
    cd ../lib
    __UNTAGGED_READ_MODE=V6 $NODE_BIN initInstance.js
    export CONFIG_FILE="${INSTANCE_DIR}/workspace/app-server/serverConfig/server.json"
    cd ../bin
  fi
elif [ -e "${HOME}/.zowe/workspace/app-server/serverConfig/server.json" ]
then
  export CONFIG_FILE="${HOME}/.zowe/workspace/app-server/serverConfig/server.json"
  mkdir -p ${INSTANCE_DIR}/logs
  export INSTANCE_DIR="${HOME}/.zowe"
elif [ -e "../deploy/instance/ZLUX/serverConfig/zluxserver.json" ]
then
  echo "WARNING: Using old configuration present in ${dir}/../deploy\n\
This configuration should be migrated for use with future versions. See documentation for more information.\n"
  export CONFIG_FILE="../deploy/instance/ZLUX/serverConfig/zluxserver.json"
else
  echo "No config file found, initializing..."
  export INSTANCE_DIR="${HOME}/.zowe"
  mkdir -p ${INSTANCE_DIR}/logs
  cd ../lib
  __UNTAGGED_READ_MODE=V6 $NODE_BIN initInstance.js
  export CONFIG_FILE="${HOME}/.zowe/workspace/app-server/serverConfig/server.json"
  cd ../bin
fi
