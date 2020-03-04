This page is used to summary all kernel related issue I met or solved for reference
-------------------------------------
# 1 ping 通 curl 不通 Using NAT
```
net.ipv4.tcp_timestamps参数设置

在使用 iptables 做 nat 时，发现内网机器 ping 某个域名 ping 的通，而使用 curl 测试不通

原来是 net.ipv4.tcp_timestamps 设置了为 1 ，即启用时间戳

cat /proc/sys/net/ipv4/tcp_timestamps

这时将其关闭

修改 /etc/sysctl.conf 中

net.ipv4.tcp_timestamps = 0

sysctl -p

生效

原理

问题出在了 tcp 三次握手，ping 的通 icmp ok ，http ssh mysql 都不 ok

经过nat之后，如果前面相同的端口被使用过，且时间戳大于这个链接发出的syn中的时间戳，服务器上就会忽略掉这个syn，不返会syn-ack消息，表现为用户无法正常完成tcp3次握手，从而不能打开web页面。在业务闲时，如果用户nat的端口没有被使用过时，就可以正常打开；业务忙时，nat端口重复使用的频率高，很难分到没有被使用的端口，从而产生这种问题。

只有客户端和服务端都开启时间戳的情况下，才会出现能ping通不能建立tcp三次握手的情况
```
