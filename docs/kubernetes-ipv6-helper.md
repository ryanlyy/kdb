Kubernetes IPv6 Support
-----------------------------
# Docker IPv6 Support

# Kubernetes IPv6 Support
## NTAS Kubelet Startup
```
Ansible Playbook: /usr/libexec/nokia/ansible/roles/kubelet
```
* Container Infra Environment
```
[ntas5 root@cbam-b3406186036c44549fb1f4d7649-oam-node-1 local]$ cat container-versions.yaml
container:
  infra:
    haproxy: "{{ main_registry_domain }}:{{ main_registry_port }}/infra/haproxy:v1.7.5-4"
    hyper: "{{ main_registry_domain }}:{{ main_registry_port }}/infra/hyper:v1.8.7-3"
    networking: "{{ main_registry_domain }}:{{ main_registry_port }}/infra/networking:v1.8.3-1"
    heapster: "{{ main_registry_domain }}:{{ main_registry_port }}/infra/heapster:v1.4.2-N1-3"
    breakthru: "{{ main_registry_domain }}:{{ main_registry_port }}/infra/breakthru:v0.4.1-1"
    chart-repo-handler: "{{ main_registry_domain }}:{{ main_registry_port }}/infra/chart-repo-handler:v1.0-22"
    skydns: "{{ main_registry_domain }}:{{ main_registry_port }}/infra/skydns:v2.5.3a-2a758af-6"
    kubernetes_pause: "{{ main_registry_domain }}:{{ main_registry_port }}/infra/pause:v1.0"
    registry: "{{ main_registry_domain }}:{{ main_registry_port }}/infra/registry:v2.6.2-2"
    etcd: "{{ main_registry_domain }}:{{ main_registry_port }}/infra/etcd:v3.2.7-3"
    tiller: "{{ main_registry_domain }}:{{ main_registry_port }}/infra/tiller:v2.7.2-2"
    swift: "{{ main_registry_domain }}:{{ main_registry_port }}/infra/swift:v2.15.1-3"
[ntas5 root@cbam-b3406186036c44549fb1f4d7649-oam-node-1 local]$
```
* Kubelet Startup
** Create .kube directory
```
- name: create .kube directory in home directories
  file:
    path: "{{ item }}"
    state: directory
    mode: 0700
  with_items:
    - /etc/skel/.kube
    - /root/.kube
```
** Create kubectl config
```
- name: template kubectl config
  template:
    src: kube.config
    dest: "{{ item }}"
    mode: 0644
  with_items:
    - /etc/skel/.kube/config
    - /root/.kube/config
    - /home/.kube/config

[ntas5 root@cbam-b3406186036c44549fb1f4d7649-oam-node-1 templates]$ cat kube.config
apiVersion: v1
kind: Config
current-context: default-system
preferences: {}
contexts:
  - name: default-system
    context:
      cluster: default-cluster
      user: default-admin
clusters:
  - name: default-cluster
    cluster:
      certificate-authority: /etc/kubernetes/ssl/ca.pem
      server: https://{{ apiserver }}:6443
users:
  - name: default-admin
    user:
      client-certificate: /etc/kubernetes/ssl/kubelet{{ vtas_nodeindex }}.pem
      client-key: /etc/kubernetes/ssl/kubelet{{ vtas_nodeindex }}-key.pem
      
==>>

[ntas5 root@cbam-b3406186036c44549fb1f4d7649-oam-node-1 ansible]$ cat /root/.kube/config
apiVersion: v1
kind: Config
current-context: default-system
preferences: {}
contexts:
  - name: default-system
    context:
      cluster: default-cluster
      user: default-admin
clusters:
  - name: default-cluster
    cluster:
      certificate-authority: /etc/kubernetes/ssl/ca.pem
      server: https://127.0.0.1:6443
users:
  - name: default-admin
    user:
      client-certificate: /etc/kubernetes/ssl/kubelet1.pem
      client-key: /etc/kubernetes/ssl/kubelet1-key.pem
[ntas5 root@cbam-b3406186036c44549fb1f4d7649-oam-node-1 ansible]
```
** Create libs
```
- name: create libs
  file:
    name: "{{ item }}"
    state: directory
  with_items:
    - /var/lib/kubelet
    - /etc/kubernetes/manifests
    - /etc/kubernetes/kubeconfig

```

** Create app side resolv.conf
```
- name: template app side resolv.conf
  template:
    src: skydns-resolv.conf
    dest: /etc/kubernetes
```

** Create env.list
```
- name: template env.list
  template:
    src: env.list
    dest: /etc/kubernetes
  notify:
    - restart kubelet

[ntas5 root@cbam-b3406186036c44549fb1f4d7649-oam-node-1 tasks]$ cat ../templates/env.list
API_SERVERS=https://{{ apiserver }}:6443
CA_CERT=/etc/openssl/ca.pem
KUBE_CERT=/etc/kubernetes/ssl/kubelet{{ vtas_nodeindex }}.pem
KUBE_KEY=/etc/kubernetes/ssl/kubelet{{ vtas_nodeindex }}-key.pem
API_CERT=/etc/kubernetes/ssl/apiserver{{ vtas_nodeindex }}.pem
API_KEY=/etc/kubernetes/ssl/apiserver{{ vtas_nodeindex }}-key.pem
DOCKER_CERT=/etc/docker/docker{{ vtas_nodeindex }}.pem
DOCKER_KEY=/etc/docker/docker{{ vtas_nodeindex }}-key.pem
DPLUG_CERT=/etc/kubernetes/ssl/dplug{{ vtas_nodeindex }}.pem
DPLUG_KEY=/etc/kubernetes/ssl/dplug{{ vtas_nodeindex }}-key.pem
CLIENT_CERT=/etc/docker/client{{ vtas_nodeindex }}.pem
CLIENT_KEY=/etc/docker/client{{ vtas_nodeindex }}-key.pem
HOST_IP={{ infra_int_ip }}
RESOLV_CONF=/etc/kubernetes/skydns-resolv.conf
CLUSTER_DNS=10.254.0.10
DOCKER_API=1.27
DOCKER_HOST=tcp://{{ infra_int_ip }}:2375
DOCKER_TLS_VERIFY=1
DOCKER_CERT_PATH=/rootfs/etc/docker
LOCALDOMAIN=novalocal
{% if vtas_nodetype in not_scalable_nodes %}
NODE_LABELS=nodetype={{ vtas_nodetype }},nodeindex={{ vtas_nodeindex }},nodename={{ vtas_nodename }},nodehost={{ vtas_nodehost }}
{% else %}
NODE_LABELS=nodetype={{ vtas_nodetype }}-unschedulable,nodehost={{ vtas_nodehost }}
{% endif %}
[ntas5 root@cbam-b3406186036c44549fb1f4d7649-oam-node-1 tasks]$

==>>
[ntas5 root@cbam-b3406186036c44549fb1f4d7649-oam-node-1 tasks]$ cat /etc/kubernetes/env.list
API_SERVERS=https://127.0.0.1:6443
CA_CERT=/etc/openssl/ca.pem
KUBE_CERT=/etc/kubernetes/ssl/kubelet1.pem
KUBE_KEY=/etc/kubernetes/ssl/kubelet1-key.pem
API_CERT=/etc/kubernetes/ssl/apiserver1.pem
API_KEY=/etc/kubernetes/ssl/apiserver1-key.pem
DOCKER_CERT=/etc/docker/docker1.pem
DOCKER_KEY=/etc/docker/docker1-key.pem
DPLUG_CERT=/etc/kubernetes/ssl/dplug1.pem
DPLUG_KEY=/etc/kubernetes/ssl/dplug1-key.pem
CLIENT_CERT=/etc/docker/client1.pem
CLIENT_KEY=/etc/docker/client1-key.pem
HOST_IP=172.24.16.105
RESOLV_CONF=/etc/kubernetes/skydns-resolv.conf
CLUSTER_DNS=10.254.0.10
DOCKER_API=1.27
DOCKER_HOST=tcp://172.24.16.105:2375
DOCKER_TLS_VERIFY=1
DOCKER_CERT_PATH=/rootfs/etc/docker
LOCALDOMAIN=novalocal
NODE_LABELS=nodetype=oam,nodeindex=1,nodename=oam1,nodehost=cbam-b3406186036c44549fb1f4d76498f906-oam-node-1
[ntas5 root@cbam-b3406186036c44549fb1f4d7649-oam-node-1 tasks]$

```

