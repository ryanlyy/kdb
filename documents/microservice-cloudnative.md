MicroService and CloudNative Homepage
-----------------------
# Application Robustness 
  – Make a stable system in unstable environment
* Hardware Performance Independence
  * disk independence: disk access w/ buffer supported and standalone thread
  * network independence: network access w/ buffer supported and standalone thread
* Packet Fault Tolerance
  * Check it is valid format you can support

# Principles 
http://peter.bourgon.org/blog/2017/02/21/metrics-tracing-and-logging.html
* Logging
  * Flexibility - STDOUT
  * docker with fluentd plugin
  * filebeat to Elasticsearch
* API
  * RESTful
  * GRPC
* Dataless
  * 
* Common Transport Middleware
  * (Hook) Tracing System Embedded
