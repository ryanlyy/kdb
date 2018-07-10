Kubernetes IPv6 Support
-----------------------------
# Docker IPv6 Support

# Kubernetes IPv6 Support
## NTAS Kubelet Startup
```
Ansible Playbook: /usr/libexec/nokia/ansible/roles/kubelet
```
* Container Infra Image
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
* 
