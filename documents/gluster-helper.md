# Go to Gluster Container
```
# kubectl get pod |grep gluster
glusterfs-kh849                             1/1     Running     0          2d11h
glusterfs-qhx7v                             1/1     Running     0          2d11h
glusterfs-vndsb                             1/1     Running     0          2d11h
# kubectl exec -ti glusterfs-kh849 bash
```
# Gluster Cluster
## Gluster Cluster Status
```
gluster
gluster> peer status
Number of Peers: 2

Hostname: infra1
Uuid: ffa98c9e-2a72-470f-a180-52179d8adbd9
State: Peer in Cluster (Connected)

Hostname: 
Uuid: b7c164d7-0884-40a1-a603-e2ba964b309f
State: Peer in Cluster (Connected)
gluster>
```
## Gluster Cluster detach and probe
```
peer detach { <HOSTNAME> | <IP-address> } [force] - detach peer specified by <HOSTNAME>
peer probe { <HOSTNAME> | <IP-address> } - probe peer specified by <HOSTNAME>
```
## Gluster Cluster Pool
```
gluster> pool list
UUID                                    Hostname                                                                State
ffa98c9e-2a72-470f-a180-52179d8adbd9    infra1                                                                  Connected
b7c164d7-0884-40a1-a603-e2ba964b309f    net  Connected
42ea366c-bbca-4d50-b7f9-745ac5e9b570    localhost                                                               Connected
```
# Gluster Volume
## Volume list
```
gluster> volume list
oam
oam_enc
troubleshooting
gluster>
```
## Volume status
```
gluster> volume status

gluster>
```

## Volume info
```
gluster> volume info


```
## remove and add brick
```
3, Remove the bricks for the problem storage node with command "gluster volume remove-brick"
gluster volume remove-brick oam_enc replica 2 172.24.16.104:/mnt/bricks/oam_enc force

4, add the bricks back after the HW replacement with command "gluster volume add-brick"
gluster volume add-brick oam_enc replica 3 172.24.16.104:/mnt/bricks/oam_enc force
```

## Volume commands
```
gluster volume commands
========================

volume add-brick <VOLNAME> [<stripe|replica> <COUNT> [arbiter <COUNT>]] <NEW-BRICK> ... [force] - add brick to volume <VOLNAME>
volume barrier <VOLNAME> {enable|disable} - Barrier/unbarrier file operations on a volume
volume clear-locks <VOLNAME> <path> kind {blocked|granted|all}{inode [range]|entry [basename]|posix [range]} - Clear locks held on path
volume create <NEW-VOLNAME> [stripe <COUNT>] [replica <COUNT> [arbiter <COUNT>]] [disperse [<COUNT>]] [disperse-data <COUNT>] [redundancy <COUNT>] [transport <tcp|rdma|tcp,rdma>] <NEW-BRICK>?<vg_name>... [force] - create a new volume of specified type with mentioned bricks
volume delete <VOLNAME> - delete volume specified by <VOLNAME>
volume get <VOLNAME|all> <key|all> - Get the value of the all options or given option for volume <VOLNAME> or all option. gluster volume get all all is to get all global options
volume heal <VOLNAME> [enable | disable | full |statistics [heal-count [replica <HOSTNAME:BRICKNAME>]] |info [summary | split-brain] |split-brain {bigger-file <FILE> | latest-mtime <FILE> |source-brick <HOSTNAME:BRICKNAME> [<FILE>]} |granular-entry-heal {enable | disable}] - self-heal commands on volume specified by <VOLNAME>
volume help - display help for volume commands
volume info [all|<VOLNAME>] - list information of all volumes
volume list - list all volumes in cluster
volume log <VOLNAME> rotate [BRICK] - rotate the log file for corresponding volume/brick
volume log rotate <VOLNAME> [BRICK] - rotate the log file for corresponding volume/brick NOTE: This is an old syntax, will be deprecated from next release.
volume profile <VOLNAME> {start|info [peek|incremental [peek]|cumulative|clear]|stop} [nfs] - volume profile operations
volume rebalance <VOLNAME> {{fix-layout start} | {start [force]|stop|status}} - rebalance operations
volume remove-brick <VOLNAME> [replica <COUNT>] <BRICK> ... <start|stop|status|commit|force> - remove brick from volume <VOLNAME>
volume replace-brick <VOLNAME> <SOURCE-BRICK> <NEW-BRICK> {commit force} - replace-brick operations
volume reset <VOLNAME> [option] [force] - reset all the reconfigured options
volume reset-brick <VOLNAME> <SOURCE-BRICK> {{start} | {<NEW-BRICK> commit}} - reset-brick operations
volume set <VOLNAME> <KEY> <VALUE> - set options for volume <VOLNAME>
volume start <VOLNAME> [force] - start volume specified by <VOLNAME>
volume statedump <VOLNAME> [[nfs|quotad] [all|mem|iobuf|callpool|priv|fd|inode|history]... | [client <hostname:process-id>]] - perform statedump on bricks
volume status [all | <VOLNAME> [nfs|shd|<BRICK>|quotad|tierd]] [detail|clients|mem|inode|fd|callpool|tasks|client-list] - display status of all or specified volume(s)/brick
volume stop <VOLNAME> [force] - stop volume specified by <VOLNAME>
volume sync <HOSTNAME> [all|<VOLNAME>] - sync the volume information from a peer
volume top <VOLNAME> {open|read|write|opendir|readdir|clear} [nfs|brick <brick>] [list-cnt <value>] |
volume top <VOLNAME> {read-perf|write-perf} [bs <size> count <count>] [brick <brick>] [list-cnt <value>] - volume top operations
```

# Q&A
## XFS (vdc2): xfs_log_force: error -5 returned
```
[   77.691772] XFS (dm-1): xfs_do_force_shutdown(0x8) called from line 985 of file fs/xfs/xfs_trans.c.  Return address = 0xffffffffc0d5335f
[   77.691774] XFS (dm-1): Corruption of in-memory data detected.  Shutting down filesystem
[   77.691775] XFS (dm-1): Please umount the filesystem and rectify the problem(s)
[   77.691778] XFS (dm-1): Failed to recover intents
[   77.691778] XFS (dm-1): log mount finish failed
[   77.691786] XFS (dm-1): xfs_log_force: error -5 returned.
```
```
#xfs_info /mnt
kubectl label no cbam-0e940d20ef4d4972abc1f01e472-storage-node-2 nodtype-
umount /dev/vdc2
#mkfs.xfs -f /dev/mapper/fedora-root
#mout /dev/mapper/fedora-root /mnt
xfs_repair -L /dev/vdc2 
#xfs_metadump /dev/mapper/fedora-root /tmp/xfs_dump
mount -a
kubectl label no cbam-0e940d20ef4d4972abc1f01e472-storage-node-2 nodtype=storage
```
```
gluster volume stop oam
gluster volume delete oam
<gluster volume create oam>
gluster volume set oam cluaster.server-quorum-type server
gluster volume set oam cluster.quorum-type auto
gluster volume set oam nfs.disable on
gluster volume set oam diagnostics.brick-sys-log-level INFO
gluster volume start oam
gluster volume status oam
```
