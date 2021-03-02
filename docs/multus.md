Multus with Calico (default) and ipvlan, macvlan, DANM Configuration
---------------------------------

# 0. Prerequisites
The followings are been installed correctly:
* Kubernetes default network plugin (i.e: calico)
* Danm including netwatcher, webhook, svcwatcher, crd etc.

# 1. Install Multus
 * git clone https://github.com/intel/multus-cni.git
 * git checkout release-3.5
 * cd multus-cni
 * cat ./images/multus-daemonset.yml | kubectl apply -f -
 ```
 What multus-daemonset do:
 ** Copy cni plugin "multus" to /opt/cni/bin
 ** Generate kubeconfig to /etc/cni/net.d/multus.d
 ** Generate 00-multus.conf to /et/cni/net.d
 ```
```
[root@localhost net.d]# kubectl get pods --all-namespaces | grep -i multus
kube-system       kube-multus-ds-amd64-drkbx                      1/1     Running   0          5m51s
```
```
[root@localhost net.d]# cat 00-multus.conf | python -m json.tool
{
    "cniVersion": "0.3.1",
    "name": "multus-cni-network",
    "type": "multus",
    "kubeconfig": "/etc/cni/net.d/multus.d/multus.kubeconfig",
    "delegates": [
        {
            "name": "k8s-pod-network",
            "cniVersion": "0.3.1",
            "plugins": [
                {
                    "type": "calico",
                    "datastore_type": "kubernetes",
                    "mtu": 1410,
                    "nodename_file_optional": false,
                    "log_file_path": "/var/log/calico/cni/cni.log",
                    "ipam": {
                        "type": "calico-ipam",
                        "assign_ipv4": "true",
                        "assign_ipv6": "false"
                    },
                    "container_settings": {
                        "allow_ip_forwarding": false
                    },
                    "policy": {
                        "type": "k8s"
                    },
                    "kubernetes": {
                        "kubeconfig": "/etc/cni/net.d/calico-kubeconfig"
                    }
                },
                {
                    "type": "portmap",
                    "snat": true,
                    "capabilities": {
                        "portMappings": true
                    }
                }
            ]
        }
    ]
}
```

# 2. Install MACVLAN as secondary Interface (optional if need macvlan)
```
# macvlan.yaml
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: macvlan-conf
spec:
  config: '{
      "cniVersion": "0.3.0",
      "type": "macvlan",
      "master": "enp0s3",
      "mode": "bridge",
      "ipam": {
        "type": "host-local",
        "subnet": "10.168.1.0/24",
        "rangeStart": "10.168.1.200",
        "rangeEnd": "10.168.1.216",
        "routes": [
          { "dst": "0.0.0.0/0" }
        ],
        "gateway": "10.168.1.1"
      }
    }'
```
```
 kubectl apply -f macvlan.yaml
```
* Test second Interface
```
apiVersion: v1
kind: Pod
metadata:
  name: samplepod
  annotations:
    k8s.v1.cni.cncf.io/networks: macvlan-conf
spec:
  containers:
  - name: samplepod
    command: ["/bin/ash", "-c", "trap : TERM INT; sleep infinity & wait"]
    image: alpine
```
```
[root@localhost test]# kubectl exec -ti samplepod -- ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
3: eth0@if12: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1410 qdisc noqueue state UP
    link/ether e6:7e:6c:fe:0d:65 brd ff:ff:ff:ff:ff:ff
    inet 192.168.102.134/32 brd 192.168.102.134 scope global eth0
       valid_lft forever preferred_lft forever
4: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UP
    link/ether c6:f8:b9:55:eb:ac brd ff:ff:ff:ff:ff:ff
    inet 10.168.1.200/24 brd 10.168.1.255 scope global net1
       valid_lft forever preferred_lft forever
```

# 3. Intall IPvlan as secondary interface (optional if need ipvlan)
```
#ipvlan.yaml

apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: ipvlan-conf
spec:
  config: '{
        "name": "ipvlan",
        "type": "ipvlan",
        "master": "enp0s3",
        "ipam": {
                "type": "host-local",
                "subnet": "10.1.2.0/24"
        }
    }'
```
```
kubectl apply -f ipvlan.yaml
```

* Test secondary interface:
```
apiVersion: v1
kind: Pod
metadata:
  name: samplepod3
  annotations:
    k8s.v1.cni.cncf.io/networks: ipvlan-conf
    danm.k8s.io/interfaces: |
      [
        {"clusterNetwork": "default", "ip": "dynamic" },
        {"clusterNetwork": "oampub", "ip":"dynamic"}
      ]
spec:
  containers:
  - name: samplepod3
    command: ["/bin/ash", "-c", "trap : TERM INT; sleep infinity & wait"]
    image: alpine:20201021
```
```
[root@localhost test]# kubectl exec -ti samplepod3 -- ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if540: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1410 qdisc noqueue state UP
    link/ether 86:7c:bc:af:6d:38 brd ff:ff:ff:ff:ff:ff
    inet 192.168.102.158/32 brd 192.168.102.158 scope global eth0
       valid_lft forever preferred_lft forever
4: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether 08:00:27:b0:4c:0e brd ff:ff:ff:ff:ff:ff
    inet 10.1.2.2/24 brd 10.1.2.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fe80::800:2700:49b0:4c0e/64 scope link
       valid_lft forever preferred_lft forever
539: oampub1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether 08:00:27:b0:4c:0e brd ff:ff:ff:ff:ff:ff
    inet 10.2.157.2/27 brd 10.2.157.31 scope global oampub1
       valid_lft forever preferred_lft forever
[root@localhost test
```
# 4. Integrate DANM to multus
NOTE: danm MUST be initial (first) NetworkAttachmentDefinition in multus because  of the following code in danm:
---
```
func calculateIfaceName(namingScheme, chosenName, defaultName string, sequenceId int) string {
  //Kubelet expects the first interface to be literally named "eth0", so...
  if sequenceId == 0 {
    return "eth0"
  }
```

The in order to support danm using multus w/ calico as default (first) device, the multus configuration shall be:
```
/etc/cni/net.d/00-multus.conf
{
    "cniVersion": "0.3.1",
    "name": "multus-cni-network",
    "type": "multus",
    "kubeconfig": "/etc/cni/net.d/multus.d/multus.kubeconfig",
    "delegates": [
        {
                    "cniVersion": "0.3.1",
                    "name": "danm",
                    "type": "danm",
                    "kubeconfig": "/etc/kubernetes/kubeconfig/danm-cni.yaml",
                    "namingScheme": "awesome"
        }
    ]
}
```
Calico Configuration as default network:
```
/etc/cni/net.d/default.conf
{
      "name": "calico",
      "type": "calico",
      "datastore_type": "kubernetes",
      "mtu": 1410,
      "nodename_file_optional": false,
      "log_file_path": "/var/log/calico/cni/cni.log",
      "ipam": {
          "type": "calico-ipam",
          "assign_ipv4" : "true",
          "assign_ipv6" : "false"
      },
      "container_settings": {
          "allow_ip_forwarding": true
      },
      "policy": {
          "type": "k8s"
      },
      "kubernetes": {
          "kubeconfig": "/etc/cni/net.d/calico-kubeconfig"
      },
      "masterplugin": true
}
```
Test Pod manfiest:
```
apiVersion: v1
kind: Pod
metadata:
  name: samplepod-danm
  annotations:
    danm.k8s.io/interfaces: |
      [
        {"clusterNetwork": "default", "ip": "dynamic" },
        {"clusterNetwork": "oampub", "ip":"dynamic"}
      ]
spec:
  containers:
  - name: samplepod-danm
    command: ["/bin/ash", "-c", "trap : TERM INT; sleep infinity & wait"]
    image: alpine:20201021
```
```
[root@localhost test]# kubectl exec -ti samplepod-danm -- ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if393: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1410 qdisc noqueue state UP
    link/ether 76:0e:ec:c7:76:da brd ff:ff:ff:ff:ff:ff
    inet 192.168.102.141/32 brd 192.168.102.141 scope global eth0
       valid_lft forever preferred_lft forever
392: oampub1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue state UNKNOWN
    link/ether 08:00:27:b0:4c:0e brd ff:ff:ff:ff:ff:ff
    inet 10.2.157.1/27 brd 10.2.157.31 scope global oampub1
       valid_lft forever preferred_lft forever
[root@localhost test]#
```
Danm network configuraiton:
```
apiVersion: danm.k8s.io/v1
kind: ClusterNetwork
metadata:
  name: default
spec:
  NetworkID: default
  NetworkType: calico
```
"host_device" shall be mapping with host real device NIC
```
apiVersion: danm.k8s.io/v1
kind: ClusterNetwork
metadata:
  name: oampub
spec:
  NetworkID: oampub
  NetworkType: ipvlan
  Options:
    alloc: gBCAAQ==
    allocation_pool:
      end: 10.2.157.30
      lastIp: ""
      start: 10.2.157.1
    cidr: 10.2.157.0/27
    container_prefix: oampub
    host_device: enp0s3
    rt_tables: 107
```



