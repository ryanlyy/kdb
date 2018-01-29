#!/usr/bin/bash

if [[ $# -le 2 ]]; then
        echo "$0 podname -- <cmd run in container>"
        exit -1
fi

PARA_LIST=$*
CMD_LIST=${PARA_LIST#*--}
POD_NAME=${PARA_LIST%--*}
DOCKER_ID=$(docker ps |grep $POD_NAME | grep -v pause | awk '{ print $1 }')
nsenter -n -p -t $(docker inspect --format='{{ .State.Pid }}' $DOCKER_ID) $CMD_LIST
