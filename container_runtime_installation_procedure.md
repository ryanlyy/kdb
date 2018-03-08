This is procedure to install container runtime environment under kebernetes support

# Install Fedora Cloud Qcow2
* Qcow2 URL

http://mirror.math.princeton.edu/pub/fedora/linux/releases/26/CloudImages/x86_64/images/

* Configure Fedora username/passwd = fedora/fedora in userdata
```
#cloud-config
password: fedora
chpasswd: { expire: False }
```
* sudo passwd root

w/: newsys
* Setup SSH Tunnel Proxy
```
export http_proxy=http://127.0.0.1:6699 **
export https_proxy=https://127.0.0.1:6699
export no_proxy="127.0.0.1, localhost, 192.168.122.218"
```
# Install Docker
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
# Install Kubernetes
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
kubeadm init --pod-network-cidr=10.244.0.0/16
      --token string                            The token to use for establishing bidirectional trust between nodes and masters.
      --token-ttl duration                      The duration before the bootstrap token is automatically deleted. 0 means 'never expires'. (default 24
```
* CNI Plugin Location

https://github.com/projectcalico/cni-plugin/releases/download/v1.9.1/

https://github.com/projectcalico/cni-plugin/releases/download/v1.9.1/portmap
# Flannel Installation
```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
kubectl taint nodes --all node-role.kubernetes.io/master-
```
# Install danm
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

# Install helm
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
# Install NTAS and SIM
```
NOTE: Update NIC Name
kubectl create -f /nokia/ntas1212/helm/ntas1107/helm-charts/ntas_danm/manifests/skydns-kubedns-cm.yaml
ETCD_URL in valule should add "." at last
DTD needs sctp: modprobe sctp
```
# Install Chart Repes
```
mkdir -p /var/chart-repo
kubectl create -f chart-repo.yaml
mkdir -p /nokia/chart-repo-backup
kubectl create -f chart-repo-svc.yaml
```
# Install Robot
```
kubectl create -f robot_rbac.yaml
```
# Install JENKINS
```
	1. kubectl label node ntas-cd-demo-fedora.localdomain nodetype=oam
	2. update proxy
	3. curl -s http://127.0.0.1:8080/job/tas01-auto-setup/lastBuild/api/json | grep "\"building\":true" > /dev/null

root@jenkins-jenkins-8588fb7894-p2xm6:/robot/bin# curl http://127.0.0.1:8080/job/tas01-auto-setup/lastBuild/api/json?token=tas01
{"_class":"hudson.model.FreeStyleBuild","actions":[{"_class":"hudson.model.CauseAction","causes":[{"_class":"hudson.model.Cause$UserIdCause","shortDescription":"Started by user admin","userId":"admin","userName":"admin"}]},{}],"artifacts":[],"building":false,"description":null,"displayName":"#9","duration":205054,"estimatedDuration":4988005,"executor":null,"fullDisplayName":"tas01-auto-setup #9","id":"9","keepLog":false,"number":9,"queueId":9,"result":"SUCCESS","timestamp":1513572611407,"url":"http://135.2.157.29:32666/job/tas01-auto-setup/9/","builtOn":"","changeSet":{"_class":"hudson.scm.EmptyChangeLogSet","items":[],"kind":null}}root@jenkins-jenkins-8588fb7894-p2xm6:/robot/bin#
```
# Install heaspter
```
kubectl create -f heapster.yaml
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
# Install ELK
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

# Slave Join
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