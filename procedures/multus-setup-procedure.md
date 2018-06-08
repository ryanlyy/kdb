The procedure to setup multus plugin for Kubernetes
==================

# 1. Create CRD networking:

* kubectl create -f ./multus_rd.yaml

```
cat <<EOF > multus_crd.yaml  
apiVersion: apiextensions.k8s.io/v1beta1  
kind: CustomResourceDefinition  
metadata:  
  # name must match the spec fields below, and be in the form: <plural>.<group>  
  name: networks.kubernetes.com  
spec:  
  # group name to use for REST API: /apis/<group>/<version>  
  group: kubernetes.com  
  # version name to use for REST API: /apis/<group>/<version>  
  version: v1  
  # either Namespaced or Cluster  
  scope: Namespaced  
  names:  
    # plural name to be used in the URL: /apis/<group>/<version>/<plural>  
    plural: networks  
    # singular name to be used as an alias on the CLI and for display  
    singular: network  
    # kind is normally the CamelCased singular type. Your resource manifests use this.  
    kind: Network  
    # shortNames allow shorter string to match your resource on the CLI  
    shortNames:  
    - net  
EOF  
```

# 2. Add flannel Networking:
* kubectl create -f ./flannel-network.yaml  

```
cat <<EOF > flannel-network.yaml  
apiVersion: "kubernetes.com/v1"  
kind: Network  
metadata:  
  name: flannel-networkobj  
plugin: flannel  
args: '[  
        {  
                "delegate": {  
                        "isDefaultGateway": true  
                }  
        }  
]'  
EOF  
```

# 3. Add Weave Networking:
* kubectl create -f ./weave-network.yaml

```
cat <<EOF > weave-network.yaml  
apiVersion: "kubernetes.com/v1"  
kind: Network  
metadata:  
  name: weave-networkobj  
plugin: weave-net  
args: '[  
        {  
                "hairpinMode": true  
        }  
]'  
EOF  
```

# 4. Add DANM Networking: 
* kubectl create -f ./danm-network.yaml

```
cat <<EOF > danm-network.yaml  
apiVersion: "kubernetes.com/v1"  
kind: Network  
metadata:  
  name: danm  
plugin: danm  
args: '[{"noargs": true}]'  
EOF  
```

# 5. Config CNI configuration:
* systemctl restart kubelet

```
cat <<EOF > /etc/cni/net.d/00-multus.conf  
{  
  "name": "multus-cni-network",  
  "type": "multus",  
  "kubeconfig": "/etc/kubernetes/admin.conf",  
  "delegates": [  
        {  
                "type": "flannel",  
                "masterplugin": true,  
                "delegate": {  
                        "isDefaultGateway": true  
                }  
        }  
   ]  
}  
EOF  
```
NOTE: 
In this above config, flannel acts as the default network in the absence of network field in the pod metadata annotation.

* Make sure there is no other config from other plugins
```
For Flannel: Update flannel manifest to remove init container which is used to copy 10-flannel.conf to /etc/cni/net.d
For Weave: it is weave container to generate 10-weave.conf when it is started. So need a new container for multus to monitor this /etc/cni/net.d as mounted volume when there is other conf, remove it and restart kubelet service.
```
# 6. Install Multus:
* Download from https://github.com/Intel-Corp/multus-cni/
* Build it

# 7. Install Flannel:
* kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
* For flannel to work correctly, --pod-network-cidr=10.244.0.0/16 has to be passed to kubeadm init.
* sysctl -w net.bridge.bridge-nf-call-iptables=1 to pass bridged IPv4 traffic to iptables’ chains

```
for multiple interface on host, please specifiy interface for inter communication
spec:
  containers:
  - command:
    - /opt/bin/flanneld
    - --ip-masq
    - --kube-subnet-mgr
    - --iface=eth5
    env:
```

# 8. Install Weave:
* export kubever=$(kubectl version | base64 | tr -d '\n')
* kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever";

# 9. Install DANM:
## Create Danmnet CRD
```
cat <<EOF > danmnet-crd.yaml 
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: danmnets.kubernetes.nokia.com
spec:
  group: kubernetes.nokia.com
  names:
    kind: DanmNet
    listKind: DanmNetList
    plural: danmnets
    singular: danmnet
  scope: Namespaced
  version: v1
EOF
```
* kubectl create -f danmnet-crd.yaml
## Create DanmEp CRD
```
cat <<EOF > danmep-crd.yaml 
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: danmeps.kubernetes.nokia.com
spec:
  group: kubernetes.nokia.com
  names:
    kind: DanmEp
    listKind: DanmEpList
    plural: danmeps
    singular: danmep
  scope: Namespaced
  version: v1
EOF
```
* kubectl create -f danmep-crd.yaml
## Populate Danmnet networking
```
cat <<EOF > danmnet.yaml 
apiVersion: v1
items:
- apiVersion: kubernetes.nokia.com/v1
  kind: DanmNet
  metadata:
    clusterName: ""
    name: ctrl
    namespace: default
  spec:
    NetworkID: ctrl
    Options:
      alloc: gAAAA/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAE=
      cprfx: ctrl
      device: eth1
      end: 254
      network: 169.254.1.0
      prefix: "24"
      start: 30
      vxlan: "102"
- apiVersion: kubernetes.nokia.com/v1
  kind: DanmNet
  metadata:
    clusterName: ""
    name: ctrlpub0
    namespace: default
  spec:
    NetworkID: ctrlpub0
    Options:
      cprfx: eth5
      device: eth5
      vxlan: "200"
kind: List
metadata:
  resourceVersion: ""
  selfLink: ""
EOF
```
* kubectl create -f danmnet.yaml
## Update kubeadmin conf
```
#Add /etc/systemd/system/kubelet.service.d/10-kubeadmin.conf
Environment="CA_CERT=/etc/kubernetes/pki/ca.crt"
Environment="CERT=/etc/kubernetes/pki/apiserver-kubelet-client.crt"
Environment="KEY=/etc/kubernetes/pki/apiserver-kubelet-client.key"
Environment="API_SERVER=https://10.96.0.1" "DPLUG_HOST=http://37.12.0.18:15022"
```
NOTE: 
* Update dplug host in all nodes
* Update networking pod manifest:

** Update KUBE_APISERVER

** Update kubernets CERT Keys

```
        - name: KUBEAPI_SERVER
          value: https://135.2.157.29:6443
        - name: CA_CERT
          value: /etc/kubernetes/ssl/ca.crt
        - name: CLIENT_CERT
          value: /etc/kubernetes/ssl/apiserver-kubelet-client.crt
        - name: CLIENT_KEY
          value: /etc/kubernetes/ssl/apiserver-kubelet-client.key
```

## dplug can't be up
```
if dplug can't be up with the following log:

        #+begin_example
          dplug failed to start:  dplug has to bind dplug_host so we need to make sure dplug_host reachable and 15022 is not used.        
        #+end_example

        add hostname into "/etc/hosts" of dplug container:

        #+begin_example
          / # echo $HOSTNAME
          ntas-cd-demo-fedora.localdomain
          / # vi /dplug.py
          / # cat /etc/hosts
          127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
          ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
          37.12.0.18      ntas-cd-demo-fedora.localdomain
          / #        
        #+end_example
```

## CNI Plugin Configuration
```
* Support danm only
[root@fedora ~]# cd /etc/cni/net.d/
          [root@fedora net.d]# cat 00-danm.conf
          {
            "type":"danm",
          }
* support danm and flannel
[root@fedora ~]# cd /etc/cni/net.d/
          [root@fedora net.d]# cat 00-danm.conf
          {
            "type":"danm",
            "master": {
              "name": "cbr0",
              "type": "flannel",
              "delegate": {
                "isDefaultGateway": true
              }
            }
          }
```
# 10. Update kube-dns manifest:

*NOTE: can be ignore if CNI has default network*

* kubectl edit deployment kubedns -n kube-system

```
kube-dns:  
  template:  
    metadata:  
      annotations:  
        networks: '[ { "name": "flannel-networkobj" } ]'  
      creationTimestamp: null  
      labels:  
        k8s-app: kube-dns  
```

# 11. Slave Join Update
* Copy /etc/kubernetes/pki from master to slave
* Copy /etc/cni/net.d/* from master to slave
* Copy /opt/cni/bin/multus from master to slave
* Copy /etc/kubernetes/admin.conf from master to slave

* just keep 00-multus.conf in /etc/cni/net.d

# 12. EXAMPLE:

```
apiVersion: v1  
kind: Pod  
metadata:  
  name: multus-multi-net3  
  annotations:  
    networks: '[  
        { "name": "flannel-networkobj" },  
        { "name": "weave-networkobj" },  
        { "name": "danm" }  
    ]'  
    ctrl: '{"ip":"dynamic"}'  
    ctrlpub0: '{"ip":"169.254.3.111/24"}'  
spec:  # specification of the pod's contents  
  containers:  
  - name: multus-multi-net3  
    image: centos:2018  
    command: ["top"]  
    stdin: true  
    tty: true  
```
# 13 Setup Calico Plugin with etcd datastore
https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml

```
cat <<EOF > calico-crd.yaml
apiVersion: "kubernetes.com/v1"
kind: Network
metadata:
  name: calico-networkobj
plugin: calico
args: '[
         {
            "name": "calico-network",
            "etcd_endpoints": "http://127.0.0.1:2379",
            "etcd_key_file": "",
            "etcd_cert_file": "",
            "etcd_ca_cert_file": "",
            "log_level": "debug",
            "ipam": {
               "type": "calico-ipam"
            },
            "kubernetes": {
              "kubeconfig": "/etc/cni/net.d/calico-kubeconfig"
            }
         }
]'
EOF
```
NOTE: 
* Calico and Flannel can't coexist when Calico uses Kubernetes Datastore because both Calico and Flannel need --cluster-cidr=192.168.0.0/16 and --allocate-node-cidrs=true configured in kubernetes-control-manager

* ETCD datastore with TLS support:
```
  # Configure this with the location of your etcd cluster.
  **etcd_endpoints: "https://127.0.0.1:2379"**
  
    # If you're using TLS enabled etcd uncomment the following.
  # You must also populate the Secret below with these files.
  etcd_ca: "/calico-secrets/etcd-ca"
  etcd_cert: "/calico-secrets/etcd-cert"
  etcd_key: "/calico-secrets/etcd-key"
  
  
    # This self-hosted install expects three files with the following names.  The values
  # should be base64 encoded strings of the entire contents of each file.
  etcd-key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFb2dJQkFBS0NBUUVBc2JWT1BUOU9VMktTU1RTdGRmUTh0MDJPNjU2V1VjdE5NbEU3OXRTZjZ3Y3FVR1lPCndrODlSYzc2T1hGdDYxK1BlNEpjOUFjY2pRa1JYNmdmankwQVlyM0R5bG1tczRDSWM0SFlsZjFKc0FYdWZsV0UKOUpJTTlYbXdnQUozMkFUTFI4UnVGWHhGQjVJQktnNFJDSDNXYk55TEIzaWJhbVMybWlCeFREbVJzcEF2WXZiWgo4ZmxGbkFXWUtLMkpZS241bzhTdzBKMUdRa3pqdFBZV3hnNnhQbFJOa2MwZ0lBMkpEc0NRNUExQXdsKzdqSFhHCnpXbWlXTENZZE5JWVUzOGxSR1pNUnF1RFhrSGpHTVlzTTdwZHJSclNDWm5Gb0NQaEhaeW9PeE9OYThvQlY4MXoKU3Z3VVZkSVlOT2Q4N29SMDd1TVJpOWx4dE4wQ2VqWEFnWmZVTlFJREFRQUJBb0lCQURZeTZjM2NSUE5CbVFRaQp3TlM4ek5mTEc4L1k2bGUvL2FkZkJ6N2MwbmxJRWl1N05MMG1sYlY0enZBK0hCd3haUDF5WVE4OExBVUh3dmk5CnVnSmM0MFU2UTBDdjN4dllFOFhHMEZ2T2lHN2JJRVgvcHpGQWFodGtKZVNrM0JCU1JmMTVkMm11SVErU0JERGoKWVdhSm1xQlJFMFlRRHJhQVNRRHc3QjBuWWJ4bm91R1hCa1FvaTBOdnVFL1FWZlU5ckJxVzNZaFN5bFRBV2lZSQp4Y0VZUklKV04xd20rbVM0a3NYcEZQeFJFODF1cHJReU1xeFNVbVlTUkpNNG14MmhVNklsVHo5cVB1UTM2YysrCkp3Qk5NSDhPbnZiU1ZhaXFTL09rbU00SDNSSmlucXhxY1pUZTd0UWxLL2FNQUNDVDdLUEF3aHRVczZ4cGhseVgKTXpWanp3RUNnWUVBeHdjcXBMblZDT05QS1krVUg0Njh3K0JROFZpdWRSQ2M1SkV5SkRtYWxuWW5pSy9PdmszLwpDZXZMMHBUOVJyMEYrU0RWdFFGZnBCajlBZ0QzZXdyV0V5dWRvdzRrQzhpZlhkVDBUdTRUSlM3Vnpaa3Z6a1B3CnczY3h4Q1I5bFFaVzNjSnBsdkF5cFpIWUFMM09qVW1jWkZFRWoydUljT0ZESHhQU3FRUDhpVEVDZ1lFQTVKUFIKMkZrelc1QU1ab0p5YmdBeFZHVm4zRjk5M3VEcDJhalRVY00rbVdRV0duV0NIVzV0RXpaNkQxYUVBMEx6SkgybApuZTZiWndLNmVFOVBzcXR0ZVNEcTNZU2prREhuWm1DUGlXQTlVUWVVUy9CU0NRd3RoaFd2QmFsMHJvdERFaTF0CnVRT2pBM0x1RFJHcE9BYWFWUkNveTIrd0pzWTI3UnRRWlNZZCtrVUNnWUJhQVFhcXlaTHFXd2tnalZwNXp1M1UKVXF1b0NPZVQ3dmhVY01qUkV1K3luU29ScVJlQWZmc1l2SFpHKzdOeCt1Y3BtMHlwZHo2T0VmTFFwaWxFamtqegpFR1ZRS0lQcWhFWjFnMmtjREpQQjIrVTUvYzFkcE9ITE15cmhQWE5CSWtYRU1UZlkxelRBSlMwZVlMZDRzMUl6CkYyUk5pMTUvVlk4cURhZlZZUVVoOFFLQmdHQ2c0TkFkL1drU3Z6dENvQTlDZzVnUytsSWVDRDhGUTdhZytSeVMKZGs4d0VXd0VDd3BZR1VKTEFGU2xsVTh2cVV2ZTFmbXEyZ1UxRVJFMUxoTHhCMmx5Y2ZkTlVEdnY3TXZKdkVRdAo3QjNxSDFYdTlTOGY5OHE4TmU0bDBjN0x6b0hMdEp2SEhzMmhjMk1RK1VGWEFUMCt1cXl0dllEV3dIZUIyWDI1CkhHa2xBb0dBUGJDQWVVWVFQZUpLS0t4dGZ6Z3BCMU5Za1E3RnpaN1VFK2lJNk5VdFNYZ0FmS0dXaDBCV0puY2YKRDdpZmpBcnJFeHNTbHNTUjQvMXk0VzBSVTVTS1ZPc1hJbHd2elNJMzJHTUJvK3prSG1pYzZRYm5jNmhERmZ1TwpWcUN2TFZuSUJhQ0ZQTjlSR3lWWVVYVUhDa1hIQWYrQ3VkWWFIUjFMdkdUT0dPUUZSME09Ci0tLS0tRU5EIFJTQSBQUklWQVRFIEtFWS0tLS0tCg==
  etcd-cert: ....
  etcd-ca: ....
  
  
  ps -ef | grep apiserver
root      4264  4247  2 08:45 ?        00:03:55 kube-apiserver --insecure-port=0 --allow-privileged=true --advertise-address=135.2.157.37 --service-cluster-ip-range=10.96.0.0/12 --tls-cert-file=/etc/kubernetes/pki/apiserver.crt --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname --requestheader-allowed-names=front-proxy-client --requestheader-group-headers=X-Remote-Group --requestheader-extra-headers-prefix=X-Remote-Extra- --client-ca-file=/etc/kubernetes/pki/ca.crt --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,NodeRestriction,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota --enable-bootstrap-token-auth=true --requestheader-username-headers=X-Remote-User --service-account-key-file=/etc/kubernetes/pki/sa.pub --tls-private-key-file=/etc/kubernetes/pki/apiserver.key --secure-port=6443 --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt --authorization-mode=Node,RBAC --etcd-servers=https://127.0.0.1:2379 --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key


cat /etc/kubernetes/pki/etcd/ca.crt | base64 -w 0
cat /etc/kubernetes/pki/apiserver-etcd-client.crt | base64 -w 0
cat /etc/kubernetes/pki/apiserver-etcd-client.key | base64 -w 0
```

# 14. Reference Procedure
https://github.com/ryanlyy/toolsets/blob/master/container_runtime_installation_procedure.md
