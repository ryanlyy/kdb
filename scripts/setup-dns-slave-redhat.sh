#!/bin/bash

usage () {
  echo "Usage:"
  echo "   ./$(basename $0) nfs_master_ip"
  exit 1
}

if [ "$#" -ne 1 ]; then
  echo "Missing NFS mater node"
  usage
fi

MASTER_IP=$1

#Install NFS common
yum install -y nfs-utils
systemctl enable nfs
systemctl start nfs

#Create NFS directory
mkdir -p /NFSSHARE

#Mount the remote NFS directory to the local one
mount $MASTER_IP:/NFSSHARE /NFSSHARE
echo "$MASTER_IP:/NFSSHARE /NFSSHARE  nfs rw,sync,hard,intr 0 0" | sudo tee -a /etc/fstab
