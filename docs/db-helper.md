NTAS DB Access 
---

# subscriber db:
```
start_sqlcmd/sqlcmd --servers=169.254.0.46
SQL Command :: 169.254.0.46:21212
1> show tables;
1> select

voltadmin save -v -H 169.254.8.85 -b /voltdbroot/snapshots/ "Snapshot1"
voltadmin restore -H 169.254.8.85  /voltdbroot/snapshots/ "Snapshot1"
```

# HSS simulaotr
```
sqlite3 /var/lib/hssTestToolDb/hssTestTool.db
>.help
>.tables
>select * from public_id;
```

# Redis
```
kubectl exec -it redis redis-cli
redis-cli -h cm-redis-master
>config get * //see configuration of redis
>keys *
>hgetall key
>flushdb
>hset dtd-diameter-configuration-table.2 geographic-redundancy-settings.primary-destination-fqdn-ip hsstesttool-headless.tas01.svc.cluster.local|IP

> hget cts-parameter-record.1 peg-mmtel-traffic
"false"
> hset cts-parameter-record.1 peg-mmtel-traffic "true"
(integer) 0
> hget cts-parameter-record.1 peg-mmtel-traffic
"true"

hset ryan liu "true"
hdel ryan liu

>hgetall cmdb-status
> DBSIZE

echo "keys *" > redis-cli -h ipaddr

```

# NETCONF
```
kubectl exec -it cm-server-netconf bash
cd /root/
confd_cli -u root -g restoreEng
root@cm-server-netconf 09:20:05> show <tab>
root@cm-server-netconf 09:20:05> configure
root@cm-server-netconf 09:25:04% load replace /root/vtas-config-instance.xml
root@cm-server-netconf 09:30:03% commit

root@cm-server-netconf 11:12:20% edit vtas-configuration hostname-configuration hostname 1 host-ip-address 10.156.144.146

```
# ETCD:
```
export ETCDCTL_API=3 /usr/bin/etcdctl.bin get --prefix=true / --endpoints=[169.254.0.1:4001]
etcdctl3 get --prefix=true /
 /usr/bin/etcdctl del --prefix=true / --endpoints=[10.244.0.168:2379]
etcdctl get --keys-only=true --prefix=true /
```

# HELM:
```
helm init --clientonly
helm repo remove stable
```

# Vault
```
```


