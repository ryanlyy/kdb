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

# Q2: 127.0.0.1 always plumbed into lo?
A1: Yes. when kernel detect device with LOOPBACK flag, it will add 127.0.0.1

and ::1 will be added too but it is controlled by net.ipv6.conf.lo.disable_ipv6

```bash
root@k8s-controler-1:~# ip netns add myns
root@k8s-controler-1:~# ip netns exec myns ip addr
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
root@k8s-controler-1:~# ip netns exec myns ip link set lo up
root@k8s-controler-1:~# ip netns exec myns ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
root@k8s-controler-1:~# 

```

```golang
func (l *loopback) initialize(config *network) error {
        return netlink.LinkSetUp(&netlink.Device{LinkAttrs: netlink.LinkAttrs{Name: "lo"}})
}


        case NETDEV_UP:
                if (!inetdev_valid_mtu(dev->mtu))
                        break;
                if (dev->flags & IFF_LOOPBACK) {
                        struct in_ifaddr *ifa = inet_alloc_ifa();

                        if (ifa) {
                                INIT_HLIST_NODE(&ifa->hash);
                                ifa->ifa_local =
                                  ifa->ifa_address = htonl(INADDR_LOOPBACK);
                                ifa->ifa_prefixlen = 8;
                                ifa->ifa_mask = inet_make_mask(8);
                                in_dev_hold(in_dev);
                                ifa->ifa_dev = in_dev;
                                ifa->ifa_scope = RT_SCOPE_HOST;
                                memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
                                set_ifa_lifetime(ifa, INFINITY_LIFE_TIME,
                                                 INFINITY_LIFE_TIME);
                                ipv4_devconf_setall(in_dev);
                                neigh_parms_data_state_setall(in_dev->arp_parms);
                                inet_insert_ifa(ifa);
                        }
                }

```
