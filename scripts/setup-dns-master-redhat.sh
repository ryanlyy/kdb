#!/bin/bash

#nodeX_ip means all slave ip which need to access master node
usage () {
  echo "Usage:"
  echo "   ./$(basename $0) node1_ip node2_ip ... nodeN_ip"
  exit 1
}

if [ "$#" -lt 1 ]; then
  echo "Missing NFS slave nodes"
  usage
fi

#Install NFS kernel
yum install -y nfs-utils
systemctl enable nfs-server
systemctl start nfs-server

#Create /NFSSHARE and set permissions
mkdir -p /NFSSHARE
chmod 777 -R /NFSSHARE

#Update the /etc/exports
NFS_EXP=""
for i in $@; do
  NFS_EXP+="$i(rw,sync,no_root_squash) "
done
echo "/NFSSHARE "$NFS_EXP | sudo tee -a /etc/exports

#Restart the NFS service
exportfs -a
systemctl restart nfs-server
