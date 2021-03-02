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
```
curl -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE http://docker-registry-docker-registry.default.svc.cluster.local:5000/v2/amcimage/manifests/sha256:6de813fb93debd551ea6781e90b02f1f93efab9d882a6cd06bbd96a07188b073
```
# Delete marked manifests
Run this command in your docker registy container:
```
bin/registry garbage-collect  /etc/docker/registry/config.yml  
```

```
A list of methods and URIs are covered in the table below:
Method 	Path 	                            Entity 	  Description
GET 	  /v2/  	                          Base 	    Check that the endpoint implements Docker Registry API V2.
GET 	  /v2/<name>/tags/list 	            Tags 	    Fetch the tags under the repository identified by name.
GET 	  /v2/<name>/manifests/<reference> 	Manifest 	Fetch the manifest identified by name and reference where reference can be a tag or digest. A HEAD request can also be issued to this endpoint to obtain resource information without receiving all data.
PUT 	  /v2/<name>/manifests/<reference> 	Manifest 	Put the manifest identified by name and reference where reference can be a tag or digest.
DELETE 	/v2/<name>/manifests/<reference> 	Manifest 	Delete the manifest identified by name and reference. Note that a manifest can only be deleted by digest.
GET 	  /v2/<name>/blobs/<digest> 	      Blob 	    Retrieve the blob from the registry identified by digest. A HEAD request can also be issued to this endpoint to obtain resource information without receiving all data.
DELETE 	/v2/<name>/blobs/<digest> 	      Blob 	    Delete the blob identified by name and digest
POST 	  /v2/<name>/blobs/uploads/Initiate Blob      Upload 	Initiate a resumable blob upload. If successful, an upload location will be provided to complete the upload. Optionally, if the digest parameter is present, the request body will be used to complete the upload in a single request.
GET 	  /v2/<name>/blobs/uploads/<uuid> 	Blob      Upload Retrieve status of upload identified by uuid. The primary purpose of this endpoint is to resolve the current status of a resumable upload.
PATCH 	/v2/<name>/blobs/uploads/<uuid> 	Blob      Upload 	Upload a chunk of data for the specified upload.
PUT 	  /v2/<name>/blobs/uploads/<uuid> 	 Blob     Upload 	Complete the upload specified by uuid, optionally appending the body as the final chunk.
DELETE 	/v2/<name>/blobs/uploads/<uuid> 	Blob      Upload 	Cancel outstanding upload processes, releasing associated resources. If this is not called, the unfinished uploads will eventually timeout.
GET 	  /v2/_catalog 	                    Catalog 	Retrieve a sorted, json list of repositories available in the registry.
```

# HOW to configure log delivery mode
```
Configure the delivery mode of log messages from container to log driver

Docker provides two modes for delivering messages from the container to the log driver:

    (default) direct, blocking delivery from container to driver
    non-blocking delivery that stores log messages in an intermediate per-container ring buffer for consumption by driver

The non-blocking message delivery mode prevents applications from blocking due to logging back pressure. Applications will likely fail in unexpected ways when STDERR or STDOUT streams block.

    WARNING: When the buffer is full and a new message is enqueued, the oldest message in memory is dropped. Dropping messages is often preferred to blocking the log-writing process of an application.

The mode log option controls whether to use the blocking (default) or non-blocking message delivery.

The max-buffer-size log option controls the size of the ring buffer used for intermediate message storage when mode is set to non-blocking. max-buffer-size defaults to 1 megabyte.

The following example starts an Alpine container with log output in non-blocking mode and a 4 megabyte buffer:

$ docker run -it --log-opt mode=non-blocking --log-opt max-buffer-size=4m alpine ping 127.0.0.1
```
