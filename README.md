# toolsets
Include some tools for debugging and so on
## get_container_rootfs.sh ##
This tool is used to get rootfs of specific container in host level which input is container id. Usage: **./get_container_rootfs.sh cid|cname**

## nse ##
This tool is another version of nsenter which input parameter is pod name and cmd run in container. Usage: **./nse podname -- cmd**
