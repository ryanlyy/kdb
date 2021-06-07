Networking Tips
---

# Q1: How to make NIC ethtool settings persistent (apply automatically at boot) 
A1: https://access.redhat.com/solutions/2127401

Set the ETHTOOL_OPTS parameter in the interface's **ifcfg** file found in the **/etc/sysconfig/network-scripts/ directory**
```
ETHTOOL_OPTS="-G ${DEVICE} rx 4096"

## Setting a single option to set both rx and tx queues for ring buffer (running ethtool once to modify rx and tx)
ETHTOOL_OPTS="-G ${DEVICE} rx 4096 tx 4096"

## Setting multiple options (running ethtool multiple times)
ETHTOOL_OPTS="-G ${DEVICE} rx 4096; -A ${DEVICE} autoneg on"
```

