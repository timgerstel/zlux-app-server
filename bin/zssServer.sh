#!/bin/sh
# This program and the accompanying materials are
# made available under the terms of the Eclipse Public License v2.0 which accompanies
# this distribution, and is available at https://www.eclipse.org/legal/epl-v20.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Copyright Contributors to the Zowe Project.
## launch the ZLUX secure services server

ZSS_SCRIPT_DIR=$(cd `dirname $0` && pwd)
echo "pwd = `pwd`"
echo "Script dir = $(cd `dirname $0` && pwd)"

if [ -n "$ZSS_LOG_FILE" ]
then
  if [[ $ZSS_LOG_FILE == /* ]]
  then
    echo "Absolute log location given."
  else
    ZSS_LOG_FILE="${ZSS_SCRIPT_DIR}/${ZSS_LOG_FILE}"
    echo "Relative log location given, set to absolute path=$ZSS_LOG_FILE"
  fi
  if [ -n "$ZSS_LOG_DIR" ]
  then
    echo "ZSS_LOG_FILE set (value $ZSS_LOG_FILE).  Ignoring ZSS_LOG_DIR."
  fi
else
# _FILE was not specified; default filename, and check and maybe default _DIR
  if [ -z "$ZSS_LOG_DIR" ]
  then
    ZSS_LOG_DIR="../log"
  fi

  if [ -f "$ZSS_LOG_DIR" ]
  then
    ZSS_LOG_FILE=$ZSS_LOG_DIR
  elif [ ! -d "$ZSS_LOG_DIR" ]
  then
    echo "Will make log directory $ZSS_LOG_DIR"
    mkdir -p $ZSS_LOG_DIR
    if [ $? -ne 0 ]
    then
      echo "Cannot make log directory.  Logging disabled."
      ZSS_LOG_FILE=/dev/null
    fi
  fi

  ZLUX_ROTATE_LOGS=0
  if [ -d "$ZSS_LOG_DIR" ] && [ -z "$ZSS_LOG_FILE" ]
  then
    ZSS_LOG_FILE="$ZSS_LOG_DIR/zssServer-`date +%Y-%m-%d-%H-%M`.log"
    if [ -z "$ZSS_LOGS_TO_KEEP" ]
    then
      ZSS_LOGS_TO_KEEP=5
    fi
    echo $ZSS_LOGS_TO_KEEP|egrep '^\-?[0-9]+$' >/dev/null
    if [ $? -ne 0 ]
    then
      echo "ZSS_LOGS_TO_KEEP not a number.  Defaulting to 5."
      ZSS_LOGS_TO_KEEP=5
    fi
    if [ $ZSS_LOGS_TO_KEEP -ge 0 ]
    then
      ZLUX_ROTATE_LOGS=1
    fi
  fi

  #Clean up excess logs, if appropriate.
  if [ $ZLUX_ROTATE_LOGS -ne 0 ]
  then
    for f in `ls -r -1 $ZSS_LOG_DIR/zssServer-*.log 2>/dev/null | tail +$ZSS_LOGS_TO_KEEP`
    do
      echo zssServer.sh removing $f
      rm -f $f
    done
  fi
fi

ZSS_CHECK_DIR="$(dirname "$ZSS_LOG_FILE")"
if [ ! -d "$ZSS_CHECK_DIR" ]
then
  echo "ZSS_LOG_FILE contains nonexistent directories.  Creating $ZSS_CHECK_DIR"
  mkdir -p $ZSS_CHECK_DIR
  if [ $? -ne 0 ]
  then
    echo "Cannot make log directory.  Logging disabled."
    ZSS_LOG_FILE=/dev/null
  fi
fi
#Now sanitize final log filename: if it is relative, make it absolute before cd to js
if [ "$ZSS_LOG_FILE" != "/dev/null" ]
then
  ZSS_CHECK_DIR=$(cd "$(dirname "$ZSS_LOG_FILE")"; pwd)
  ZSS_LOG_FILE=$ZSS_CHECK_DIR/$(basename "$ZSS_LOG_FILE")
fi


echo ZSS_LOG_FILE=${ZSS_LOG_FILE}

if [ ! -e $ZSS_LOG_FILE ]
then
  touch $ZSS_LOG_FILE
  if [ $? -ne 0 ]
  then
    echo "Cannot make log file.  Logging disabled."
    ZSS_LOG_FILE=/dev/null
  fi
else
  if [ -d $ZSS_LOG_FILE ]
  then
    echo "ZSS_LOG_FILE is a directory.  Must be a file.  Logging disabled."
    ZSS_LOG_FILE=/dev/null
  fi
fi

if [ ! -w "$ZSS_LOG_FILE" ]
then
  echo file "$ZSS_LOG_FILE" is not writable. Logging disabled.
  ZSS_LOG_FILE=/dev/null
fi

#Determined log file.  Run zssServer.
export dir=`dirname "$0"`
cd $dir

_BPX_SHAREAS=NO _BPX_JOBNAME=${ZOWE_PREFIX}SZ1 ./zssServer "../deploy/instance/ZLUX/serverConfig/zluxserver.json"  2>&1 | tee $ZSS_LOG_FILE


# This program and the accompanying materials are
# made available under the terms of the Eclipse Public License v2.0 which accompanies
# this distribution, and is available at https://www.eclipse.org/legal/epl-v20.html
#
# SPDX-License-Identifier: EPL-2.0
#
# Copyright Contributors to the Zowe Project.
