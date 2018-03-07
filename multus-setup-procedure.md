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
cat <<EOF > /etc/cni/net.d/10-multus.conf  
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
** NOTE: Remove others conf under /etc/cni/net.d

# 6. Install Multus:
* Download from https://github.com/Intel-Corp/multus-cni/
* Build it

# 7. Install Flannel:
* kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
* For flannel to work correctly, --pod-network-cidr=10.244.0.0/16 has to be passed to kubeadm init.
* sysctl -w net.bridge.bridge-nf-call-iptables=1 to pass bridged IPv4 traffic to iptables’ chains

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
* Update dplug host in slave too
* Make sure manifest KUBE_APISERVER IP corect

## Keep dplug_host reachable: Update /etc/hosts
```
dplug failed to start:  dplug has to bind dplug_host so we need to make sure dplug_host reachable and 15022 is not used.
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

* just keep 10-multus.conf in /etc/cni/net.d

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
# 13. Reference Procedure
https://github.com/ryanlyy/toolsets/blob/master/container_runtime_installation_procedure.md
