# Packet Number going through rule
```bash
iptables -nxvL  --line-number
```
# SCTP Filter
```bash
iptables -A INPUT -p sctp --source-port 7878 --destination-port 7878 --chunk-types any DATA,INIT,INIT_ACK,SACK,HEARTBEAT,HEARTBEAT_ACK,COOKIE_ECHO,COOKIE_ACK -j DROP
```
