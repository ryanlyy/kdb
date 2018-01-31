This is the procedure to setup multus plugin for Kubernetes
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

# 6. Install Weave:
* export kubever=$(kubectl version | base64 | tr -d '\n')
* kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever";

# 7. Update kube-dns manifest:

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

# 8. EXAMPLE:

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
