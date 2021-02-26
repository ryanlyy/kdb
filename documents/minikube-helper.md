Minikube Installation
---

# Windows Docker Desktop Environment
1. Install minikube windows version
https://storage.googleapis.com/minikube/releases/latest/minikube-installer.exe

2. Configure proxy if needed
```
https://minikube.sigs.k8s.io/docs/handbook/vpn_and_proxy/
set HTTP_PROXY=http://<proxy hostname:port>
set HTTPS_PROXY=https://<proxy hostname:port>
set NO_PROXY=localhost,127.0.0.1,10.96.0.0/12,192.168.99.0/24,192.168.39.0/24
```

3. Manaul docker pull kubernetes images if proxy does not work

```
k8s.gcr.io/kube-proxy                     v1.20.2    43154ddb57a8   6 weeks ago     118MB
k8s.gcr.io/kube-apiserver                 v1.20.2    a8c2fdb8bf76   6 weeks ago     122MB
k8s.gcr.io/kube-controller-manager        v1.20.2    a27166429d98   6 weeks ago     116MB
k8s.gcr.io/kube-scheduler                 v1.20.2    ed2c44fbdd78   6 weeks ago     46.4MB
kubernetesui/dashboard                    v2.1.0     9a07b5b4bfac   2 months ago    226MB
gcr.io/k8s-minikube/storage-provisioner   v4         85069258b98a   2 months ago    29.7MB
kubernetesui/metrics-scraper              v1.0.4     86262685d9ab   11 months ago   36.9MB
```

4. Manual download kubeadm/ctl/kubelet and copy it to ~/.minikube/cache/linux/VERSION or ~/.minikube/case/VERSION/.
```
https://storage.googleapis.com/kubernetes-release/release/v1.20.2/bin/linux/amd64/kubelet
https://storage.googleapis.com/kubernetes-release/release/v1.20.2/bin/linux/amd64/kubeadm
https://storage.googleapis.com/kubernetes-release/release/v1.20.2/bin/linux/amd64/kubectl
```
6. minikube install

```
minikube start --docker-env "HTTPS_PROXY=http://10.158.100.2:8080" --docker-env "HTTP_PROXY=http://10.158.100.2:8080" --docker-env "NO_PROXY=localhost,127.0.0.1,10.96.0.0/12,192.168.99.0/24,192.168.39.0/24" --base-image="gcr.io/k8s-minikube/kicbase:v0.0.17"

if there is still issue, please add “--alsologtostderr --v=8” to minikube then we can see more logs.

```

# WSL2 Unbuntu Environment
