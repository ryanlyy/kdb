# Listing catalogs
```
curl http://docker-registry-docker-registry.default.svc.cluster.local:5000/v2/_catalog
```
# Listing tags for related catalog
```
curl http://docker-registry-docker-registry.default.svc.cluster.local:5000/v2/amcimage/tags/list
```
# List manifest value for related tag
```
curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET http://docker-registry-docker-registry.default.svc.cluster.local:5000/v2/amcimage/manifests/R34.33.00.6700-20180226
```
```
curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET http://docker-registry-docker-registry.default.svc.cluster.local:5000/v2/amcimage/manifests/R34.33.00.6700-20180226 2>&1 | grep Docker-Content-Digest | awk '{print ($3)}'
```
curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE http://docker-registry-docker-registry.default.svc.cluster.local:5000/v2/amcimage/manifests/sha256:6de813fb93debd551ea6781e90b02f1f93efab9d882a6cd06bbd96a07188b073

# Delete marked manifests
Run this command in your docker registy container:
```
bin/registry garbage-collect  /etc/docker/registry/config.yml  
```
