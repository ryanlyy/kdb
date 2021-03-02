#/usr/bin/bash
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 cid|cname"
    exit 1;
fi
DOCKER_ROOT="/var/lib/docker"
docker ps | grep $1 > /dev/null
if [[ $? -ne 0 ]]; then
    echo "no container with container id or name as $1"
    exit 1;
fi
STORAGE_DRIVER=$(docker info 2>&1  |grep "Storage Driver" | cut -d":" -f2 | tr -d ' ')
if [[ "$STORAGE_DRIVER" != "aufs" ]] && [[ "$STORAGE_DRIVER" != "overlay2" ]]; then
    echo "$0 only can support aufs and overlay2 stroage dirver"
    exit 1;
fi
LONG_CONTAINER_ID=$(docker inspect --format='{{ .Id }}' $1)
MOUNT_ID="$DOCKER_ROOT/image/$STORAGE_DRIVER/layerdb/mounts/$LONG_CONTAINER_ID/mount-id"
test -f $MOUNT_ID
if [[ $? -ne 0 ]]; then
    echo "mount-id is not found in directory $MOUNT_ID"
    exit 1;
fi
CONTAINER_ROOTFS_ID=$(cat $MOUNT_ID)
if [[ $STORAGE_DRIVER == "overlay2" ]]; then
    CONTAINER_ROOTFS="$DOCKER_ROOT/$STORAGE_DRIVER/$CONTAINER_ROOTFS_ID/merged"
elif [[ $STORAGE_DRIVER == "aufs" ]]; then
    CONTAINER_ROOTFS="$DOCKER_ROOT/$STORAGE_DRIVER/mnt/$CONTAINER_ROOTFS_ID"
else
    echo "not supported storage driver $STORAGE_DRIVER"
    exit 1;
fi
echo "Container $1 rootfs: $CONTAINER_ROOTFS"
exit 0;
