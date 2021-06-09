Istio Helper 
---

# Troubleshooting
* Q1:  Error creating: Internal error occurred: failed calling webhook "namespace.sidecar-injector.istio.io": Post "https://istiod.istio-system.svc:443/inject?timeout=10s": unexpected EOF

  A1: api-server is proxy enviornment enabled, remove it by updating /etc/kubernetes/manifests/kube-apiserver.yaml

  https://istio.io/latest/docs/ops/common-problems/injection/
