This is procedure to install container runtime environment under kebernetes support

# 1 Install Fedora Cloud Qcow2
* Qcow2 URL

http://mirror.math.princeton.edu/pub/fedora/linux/releases/26/CloudImages/x86_64/images/

* Configure Fedora username/passwd = fedora/fedora in userdata
```
#cloud-config
password: fedora
chpasswd: { expire: False }
```
```
Allow root access:
#!/bin/bash
# setup root access - default login: oom/oom - comment out to restrict access too ssh key only
sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
service sshd restart
echo -e "oom\noom" | passwd root
```
* sudo passwd root

w/: newsys
* Setup SSH Tunnel Proxy
```
export http_proxy=http://127.0.0.1:6699 **
export https_proxy=https://127.0.0.1:6699
export no_proxy="127.0.0.1, localhost, 192.168.122.218"
```
# 2 Install Docker
* echo "proxy=http://127.0.0.1:6699" >> /etc/dnf/dnf.conf
* sudo dnf -y update
* reboot
* sudo dnf -y install dnf-plugins-core
* sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
* sudo dnf install -y docker-ce
* systemctl enable docker
* default is cgroupfs which should be used same with kubelet, don't use systemd
```
cat << EOF > /etc/docker/daemon.json
{
"exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
```
* systemctl start docker
* Enable Docker Proxy Server
```
mkdir /etc/systemd/system/docker.service.d
cat <<EOF > /etc/systemd/system/docker.service.d/http_proxy.conf
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:6699/";
Environment="HTTPS_PROXY=https://127.0.0.1:6699/";
EOF
```
**if only install containerd**
```
git clone https://github.com/containerd/cri
cd ./cri/contrib/ansible
ansible-playbook -i hosts cri-containerd.yaml
```
**Containerd proxy configuration:**
```
[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd
Restart=always
RestartSec=5
Delegate=yes
KillMode=process
OOMScoreAdjust=-999
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
Environment="HTTP_PROXY=http://135.245.48.34:8000"
```

# 3 Install Kubernetes
* Configure Kubernetes Repos
```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```
* setenforce 0
* yum install -y kubelet kubeadm kubectl
* Configure kubeadm
```
/etc/systemd/system/kubelet.service.d/10-kubeadm.conf
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=cgroupfs"
systemctl enable kubelet && systemctl start kubelet
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```
* Kubernetes Installation
```
yum install kubeadm-1.9.0

apt-get install -y kubelet=1.10.3-00 kubeadm=1.10.3-00 kubectl=1.10.3-00
kubeadm init --pod-network-cidr  192.168.0.0/16 --apiserver-advertise-address 10.0.16.226 --token-ttl 0 --kubernetes-version v1.10.3

kubeadm init --pod-network-cidr=10.244.0.0/16
      --token string                            The token to use for establishing bidirectional trust between nodes and masters.
      --token-ttl duration                      The duration before the bootstrap token is automatically deleted. 0 means 'never expires'. (default 24
 
if kubeadm init block for long time, consider unset http_proxy and https_proxy
```
if support containerd only w/o dockerd:
```
kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket /var/run/containerd/containerd.sock --ignore-preflight-errors=all
kubeadm join 192.168.122.59:6443 --token vvjdz5.es55u8uf3vute14f --discovery-token-ca-cert-hash sha256:f18f411d0575e7afb0bf5a8942981bce9891e128ef0ac4e8e6db577452975739 --cri-socket /var/run/containerd/containerd.sock --ignore-preflight-errors=all
```

**NOTE: kubernetes can support dockerd and containerd, --cri-socket is key difference. if it specifies to /var/run/containerd.sock then kubernetes will use containerd as runtime engine. if it is /var/run/docker.sock then it will use dockerd as runtime engine**

**kubernetes does not support swap, disable swap is needed**
```
comments swap from /etc/fstab
swapoff -a
```

* CNI Plugin Location

https://github.com/projectcalico/cni-plugin/releases/download/v1.9.1/

https://github.com/projectcalico/cni-plugin/releases/download/v1.9.1/portmap

* DNS Cache Timeout Issue:
Set cache-size=0 instead of default 1000
```
  - args:
    - -v=2
    - -logtostderr
    - -configDir=/etc/k8s/dns/dnsmasq-nanny
    - -restartDnsmasq=true
    - --
    - -k
    - --cache-size=0
    - --log-facility=-
    - --server=/cluster.local/127.0.0.1#10053
    - --server=/in-addr.arpa/127.0.0.1#10053
    - --server=/ip6.arpa/127.0.0.1#10053
    image: gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.5
```
# 4 Flannel Installation
```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
kubectl taint nodes --all node-role.kubernetes.io/master-
```
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
# 5 Install danm
* Keep dplug_host reachable: Update /etc/hosts
```
dplug failed to start:  dplug has to bind dplug_host so we need to make sure dplug_host reachable and 15022 is not used.
```
* Update kubeadmin conf
```
#Add /etc/systemd/system/kubelet.service.d/10-kubeadmin.conf
"Environment="CA_CERT=/etc/kubernetes/pki/ca.crt"
Environment="CERT=/etc/kubernetes/pki/apiserver-kubelet-client.crt"
Environment="KEY=/etc/kubernetes/pki/apiserver-kubelet-client.key"
Environment="API_SERVER=https://10.96.0.1"; "DPLUG_HOST=http://37.12.0.18:15022";" 

Update dplug host in slave too
```

# 6 Install helm
* Helm Package:
```
wget https://kubernetes-helm.storage.googleapis.com/helm-v2.7.2-linux-amd64.tar.gz
helm init
```
* tiller admin
```
kubectl create -f rbac.yaml
clusterrolebinding "tiller-admin" created
[root@ntas-cd-demo-fedora helm]# cat rbac.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: tiller-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: kube-system
```
# 7 Install NTAS and SIM
```
NOTE: Update NIC Name
kubectl create -f /nokia/ntas1212/helm/ntas1107/helm-charts/ntas_danm/manifests/skydns-kubedns-cm.yaml
ETCD_URL in valule should add "." at last
DTD needs sctp: modprobe sctp
```
# 8 Install Chart Repes
```
mkdir -p /var/chart-repo
kubectl create -f chart-repo.yaml
mkdir -p /nokia/chart-repo-backup
kubectl create -f chart-repo-svc.yaml
```
# 9 Install Robot
```
kubectl create -f robot_rbac.yaml
```
# 10 Install JENKINS
```
	1. kubectl label node ntas-cd-demo-fedora.localdomain nodetype=oam
	2. update proxy
	3. curl -s http://127.0.0.1:8080/job/tas01-auto-setup/lastBuild/api/json | grep "\"building\":true" > /dev/null

root@jenkins-jenkins-8588fb7894-p2xm6:/robot/bin# curl http://127.0.0.1:8080/job/tas01-auto-setup/lastBuild/api/json?token=tas01
{"_class":"hudson.model.FreeStyleBuild","actions":[{"_class":"hudson.model.CauseAction","causes":[{"_class":"hudson.model.Cause$UserIdCause","shortDescription":"Started by user admin","userId":"admin","userName":"admin"}]},{}],"artifacts":[],"building":false,"description":null,"displayName":"#9","duration":205054,"estimatedDuration":4988005,"executor":null,"fullDisplayName":"tas01-auto-setup #9","id":"9","keepLog":false,"number":9,"queueId":9,"result":"SUCCESS","timestamp":1513572611407,"url":"http://135.2.157.29:32666/job/tas01-auto-setup/9/","builtOn":"","changeSet":{"_class":"hudson.scm.EmptyChangeLogSet","items":[],"kind":null}}root@jenkins-jenkins-8588fb7894-p2xm6:/robot/bin#
```
# 11 Install heaspter
```
kubectl create -f heapster.yaml
Update the following in heapster.yaml to speedup the speed of fetching cpu:
  - command:
    - /heapster
    - --sink=log
    - --source=kubernetes:https://kubernetes.default
    - --metric-resolution=30s

kubectl create -f heapster-svc.yaml
helm install

	1. namespace: kube-system
	2. remove proxy from the following file: cd /etc/kubernetes/manifests/

kube-apiserver.yaml
kube-control-manger.yaml
kube-schedule.yaml
systemctl restart kubelet
kubectl describe hpa -n tas01

[root@ntas-cd-demo-fedora bin]# kubectl get hpa -n tas01
NAME       REFERENCE         TARGETS           MINPODS   MAXPODS   REPLICAS   AGE
tafe-hpa   Deployment/tafe   <unknown> / 30%   1         2         1          52m
```
NOTE for kubernetes 1.9 to make hpa works
```
/etc/kubernetes/manifests/kube-controller-manager.yaml
you can add new lines and config infos.
parameter --horizontal-pod-autoscaler-use-rest-clients=false
```
https://github.com/kubernetes/kubernetes/issues/57673
# 12 Install ELK
```
1258  helm install -n kibana kibana/
[root@ntas-cd-demo-fedora kibana]# diff values.yaml ../values.ofc.yaml
2,3c2,3
<   repository: "docker.elastic.co/kibana/kibana"
<   tag: "5.4.3"
---
>   repository: "docker.elastic.co/kibana/kibana-oss"
>   tag: "6.0.0"
11,14c11,14
<   ELASTICSEARCH_URL: http://10.105.231.182:9200
<   SERVER_PORT: 5601
<   LOGGING_VERBOSE: "true"
<   SERVER_DEFAULTROUTE: "/app/kibana"
---
>   # ELASTICSEARCH_URL: http://elasticsearch-client:9200
>   # SERVER_PORT: 5601
>   # LOGGING_VERBOSE: "true"
>   # SERVER_DEFAULTROUTE: "/app/kibana"
17,18c17
<   #type: ClusterIP
<   type: NodePort
---
>   type: ClusterIP
21d19
<   nodePort: 32111

http://135.2.157.29:32111/status

1294  helm install -n fluent-bit fluent-bit
[root@ntas-cd-demo-fedora fluent-bit]# diff /root/kubernetes-charts/charts-master//stable/fluent-bit/values.yaml values.yaml
9c9
<   pullPolicy: Always
---
>   pullPolicy: IfNotPresent
12c12
<   type: forward
---
>   type: es
17c17
<     host: elasticsearch
---
>     host: 10.110.66.77

1307  helm install -n elasticsearch elasticsearch
value.yaml:
persistence:
    enabled: false

rbac:
  create: true

curl http://10.110.66.77:9200/_cat/indices?v
curl -X DELETE  http://10.105.231.182:9200/logstash-2017.12.11

https://kubernetes.io/docs/tasks/debug-application-cluster/logging-elasticsearch-kibana/
```

# 13 Slave Join
* Create a new bootstrap token and join
```
Use kubeadm token create to create a new bootstrap token, See kubeadm: Managing Tokens.
# login to master node
# create a new bootstrap token
$ kubeadm token create
abcdef.1234567890abcdef
# get root ca cert fingerprint
$ openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
e18105ef24bacebb23d694dad491e8ef1c2ea9ade944e784b1f03a15a0d5ecea
# login to the new worker node
# join to cluster
$ kubeadm join --token abcdef.1234567890abcdef --discovery-token-ca-cert-hash sha256:e18105ef24bacebb23d694dad491e8ef1c2ea9ade944e784b1f03a15a0d5ecea 1.2.3.4:6443
15:01
Note: --discovery-token-ca-cert-hash is preferred in Kubernetes 1.8 and above.
```

# 14 Docker Registry Installation
## unsecure setup 
* Install Kubernetes Charts
https://github.com/kubernetes/charts/tree/master/stable/docker-registry

* Add docker registry service fqdn to /etc/hosts on all nodes
```
10.99.218.88    docker-registry-docker-registry.default.svc.cluster.local
```
* Update /etc/systemd/system/multi-user.target.wants/docker.service to add --insecre-registry parameter
```
ExecStart=/usr/bin/dockerd --insecure-registry docker-registry-docker-registry.default.svc.cluster.local:5000
```
* Restart docker 
```
systemctl daemon-reload
systemctl restart docekr
```
NOTE: please remove proxy setup for docker or add no_proxy

* tag your container image and push it to registry
```
docker tag xxx:nnn registry_fqdn:5000/xxx:nnn
docker push registry_fqdn:5000/xxx:nnn
docker pull registry_fqdn:5000/xxx:nnn
```

# 15 Upgrade Kubernetes
* Upgrade kubeadm
```
yum install kubeadm-1.9.0
```
* Upgrde control plan
```
kubeadm upgrade plan
kubeadm upgrade apply v1.9.0
```
* Upgrade kubelet
```
kubectl drain ntas-cd-demo-fedora.localdomain  --ignore-daemonsets
yum update kubelet-1.9.0
yum update kubectl-1.9.0
systemctl restart kubelet
systemctl status kubelet
if fail check journalctl -f -u kubelet
check cgroup driver [cgroupfs | systemd]
kubectl uncordon ntas-cd-demo-fedora.localdomain
```
# 16 Rolling Update
```
minReadySeconds: 5
strategy:
  # indicate which strategy we want for rolling update
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1
```
```
    minReadySeconds:
        the bootup time of your application, Kubernetes waits specific time til the next pod creation.
        Kubernetes assume that your application is available once the pod created by default.
        If you leave this field empty, the service may be unavailable after the update process cause all the application pods are not ready yet
    maxSurge:
        amount of pods more than the desired number of Pods
        this fields can be an absolute number or the percentage
        ex. maxSurge: 1 means that there will be at most 4 pods during the update process if replicas is 3
    maxUnavailable:
        amount of pods that can be unavailable during the update process
        this fields can be a absolute number or the percentage
        this fields cannot be 0 if maxSurge is set to 0
        ex. maxUnavailable: 1 means that there will be at most 1 pod unavailable during the update process
```
https://tachingchen.com/blog/kubernetes-rolling-update-with-deployment/

## secure setup
Will add later
