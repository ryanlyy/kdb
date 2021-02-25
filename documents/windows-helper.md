# Port Forwarding 

netsh interface portproxy add v4tov4 listenport=5050 listenaddress=0.0.0.0 connectport=5050 connectaddress=172.17.21.123

It only supports tcp 

```
PS C:\WINDOWS\system32> netsh help

The following commands are available:

Commands in this context:
?              - Displays a list of commands.
add            - Adds a configuration entry to a list of entries.
advfirewall    - Changes to the `netsh advfirewall' context.
branchcache    - Changes to the `netsh branchcache' context.
bridge         - Changes to the `netsh bridge' context.
delete         - Deletes a configuration entry from a list of entries.
dhcpclient     - Changes to the `netsh dhcpclient' context.
dnsclient      - Changes to the `netsh dnsclient' context.
dump           - Displays a configuration script.
exec           - Runs a script file.
firewall       - Changes to the `netsh firewall' context.
help           - Displays a list of commands.
http           - Changes to the `netsh http' context.
interface      - Changes to the `netsh interface' context.
ipsec          - Changes to the `netsh ipsec' context.
lan            - Changes to the `netsh lan' context.
namespace      - Changes to the `netsh namespace' context.
netio          - Changes to the `netsh netio' context.
p2p            - Changes to the `netsh p2p' context.
ras            - Changes to the `netsh ras' context.
rpc            - Changes to the `netsh rpc' context.
set            - Updates configuration settings.
show           - Displays information.
wfp            - Changes to the `netsh wfp' context.
winhttp        - Changes to the `netsh winhttp' context.
winsock        - Changes to the `netsh winsock' context.
wlan           - Changes to the `netsh wlan' context.
```

```
@ECHO OFF
SET LXDISTRO=MyWSL2vm & SET WSL2PORT=3399 & SET HOSTPORT=3398
NETSH INTERFACE PORTPROXY RESET & NETSH AdvFirewall Firewall delete rule name="%LXDISTRO% Port Forward" > NUL
WSL -d %LXDISTRO% -- ip addr show eth0 ^| grep -oP '(?^<=inet\s)\d+(\.\d+){3}' > IP.TMP
SET /p IP=<IP.TMP
NETSH INTERFACE PORTPROXY ADD v4tov4 listenport=%HOSTPORT% listenaddress=0.0.0.0 connectport=%WSL2PORT% connectaddress=%IP% 
NETSH AdvFirewall Firewall add rule name="%LXDISTRO% Port Forward" dir=in action=allow protocol=TCP localport=%HOSTPORT% > NUL
ECHO WSL2 Virtual Machine %IP%:%WSL2PORT%now accepting traffic on %COMPUTERNAME%:%HOSTPORT%
```
