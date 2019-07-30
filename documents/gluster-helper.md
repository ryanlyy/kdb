# Go to Gluster Container
```
[root@cbam-03bb6f33a3ee4824833729dce57-infra-node-0 ~]# kubectl get pod |grep gluster
glusterfs-kh849                             1/1     Running     0          2d11h
glusterfs-qhx7v                             1/1     Running     0          2d11h
glusterfs-vndsb                             1/1     Running     0          2d11h
[root@cbam-03bb6f33a3ee4824833729dce57-infra-node-0 ~]# kubectl exec -ti glusterfs-kh849 bash
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

Hostname: cbam-03bb6f33a3ee4824833729dce57-infra-node-2.storage-server.nokia.net
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
b7c164d7-0884-40a1-a603-e2ba964b309f    cbam-03bb6f33a3ee4824833729dce57-infra-node-2.storage-server.nokia.net  Connected
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
Status of volume: oam
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick cbam-03bb6f33a3ee4824833729dce57-infr
a-node-1.storage-server.nokia.net:/mnt/bric
ks/oam/brick                                49152     0          Y       170
Brick cbam-03bb6f33a3ee4824833729dce57-infr
a-node-2.storage-server.nokia.net:/mnt/bric
ks/oam/brick                                49152     0          Y       96
Brick cbam-03bb6f33a3ee4824833729dce57-infr
a-node-0.storage-server.nokia.net:/mnt/bric
ks/oam/brick                                49152     0          Y       94
Self-heal Daemon on localhost               N/A       N/A        Y       191
Self-heal Daemon on cbam-03bb6f33a3ee482483
3729dce57-infra-node-2.storage-server.nokia
.net                                        N/A       N/A        Y       193
Self-heal Daemon on infra1                  N/A       N/A        Y       396

Task Status of Volume oam
------------------------------------------------------------------------------
There are no active volume tasks

Status of volume: oam_enc
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick cbam-03bb6f33a3ee4824833729dce57-infr
a-node-1.storage-server.nokia.net:/mnt/bric
ks/oam_enc/brick                            49153     0          Y       298
Brick cbam-03bb6f33a3ee4824833729dce57-infr
a-node-2.storage-server.nokia.net:/mnt/bric
ks/oam_enc/brick                            49153     0          Y       132
Brick cbam-03bb6f33a3ee4824833729dce57-infr
a-node-0.storage-server.nokia.net:/mnt/bric
ks/oam_enc/brick                            49153     0          Y       130
Self-heal Daemon on localhost               N/A       N/A        Y       191
Self-heal Daemon on infra1                  N/A       N/A        Y       396
Self-heal Daemon on cbam-03bb6f33a3ee482483
3729dce57-infra-node-2.storage-server.nokia
.net                                        N/A       N/A        Y       193

Task Status of Volume oam_enc
------------------------------------------------------------------------------
There are no active volume tasks

Status of volume: troubleshooting
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick cbam-03bb6f33a3ee4824833729dce57-infr
a-node-1.storage-server.nokia.net:/mnt/bric
ks/troubleshooting/brick                    49154     0          Y       373
Brick cbam-03bb6f33a3ee4824833729dce57-infr
a-node-2.storage-server.nokia.net:/mnt/bric
ks/troubleshooting/brick                    49154     0          Y       170
Brick cbam-03bb6f33a3ee4824833729dce57-infr
a-node-0.storage-server.nokia.net:/mnt/bric
ks/troubleshooting/brick                    49154     0          Y       168
Self-heal Daemon on localhost               N/A       N/A        Y       191
Self-heal Daemon on cbam-03bb6f33a3ee482483
3729dce57-infra-node-2.storage-server.nokia
.net                                        N/A       N/A        Y       193
Self-heal Daemon on infra1                  N/A       N/A        Y       396

Task Status of Volume troubleshooting
------------------------------------------------------------------------------
There are no active volume tasks

gluster>
```

## Volume info
```
gluster> volume info

Volume Name: oam
Type: Replicate
Volume ID: 3acd78d7-6dae-4965-a7ea-6aaa071344c5
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 3 = 3
Transport-type: tcp
Bricks:
Brick1: cbam-03bb6f33a3ee4824833729dce57-infra-node-1.storage-server.nokia.net:/mnt/bricks/oam/brick
Brick2: cbam-03bb6f33a3ee4824833729dce57-infra-node-2.storage-server.nokia.net:/mnt/bricks/oam/brick
Brick3: cbam-03bb6f33a3ee4824833729dce57-infra-node-0.storage-server.nokia.net:/mnt/bricks/oam/brick
Options Reconfigured:
diagnostics.brick-sys-log-level: INFO
cluster.server-quorum-type: server
cluster.quorum-type: auto
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off
cluster.server-quorum-ratio: 51%

Volume Name: oam_enc
Type: Replicate
Volume ID: f92c81cd-5b0f-4363-8683-479d6c7e063f
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 3 = 3
Transport-type: tcp
Bricks:
Brick1: cbam-03bb6f33a3ee4824833729dce57-infra-node-1.storage-server.nokia.net:/mnt/bricks/oam_enc/brick
Brick2: cbam-03bb6f33a3ee4824833729dce57-infra-node-2.storage-server.nokia.net:/mnt/bricks/oam_enc/brick
Brick3: cbam-03bb6f33a3ee4824833729dce57-infra-node-0.storage-server.nokia.net:/mnt/bricks/oam_enc/brick
Options Reconfigured:
diagnostics.brick-sys-log-level: INFO
encryption.master-key: /etc/glusterfs/ssl/oam_enc.key
performance.io-cache: off
performance.read-ahead: off
performance.readdir-ahead: off
performance.stat-prefetch: off
performance.open-behind: off
performance.write-behind: off
performance.quick-read: off
features.encryption: on
cluster.server-quorum-type: server
cluster.quorum-type: auto
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off
cluster.server-quorum-ratio: 51%

Volume Name: troubleshooting
Type: Replicate
Volume ID: f23982fe-c888-4ea6-bd19-45d3c80abbab
Status: Started
Snapshot Count: 0
Number of Bricks: 1 x 3 = 3
Transport-type: tcp
Bricks:
Brick1: cbam-03bb6f33a3ee4824833729dce57-infra-node-1.storage-server.nokia.net:/mnt/bricks/troubleshooting/brick
Brick2: cbam-03bb6f33a3ee4824833729dce57-infra-node-2.storage-server.nokia.net:/mnt/bricks/troubleshooting/brick
Brick3: cbam-03bb6f33a3ee4824833729dce57-infra-node-0.storage-server.nokia.net:/mnt/bricks/troubleshooting/brick
Options Reconfigured:
diagnostics.brick-sys-log-level: INFO
cluster.server-quorum-type: server
cluster.quorum-type: auto
transport.address-family: inet
nfs.disable: on
performance.client-io-threads: off
cluster.server-quorum-ratio: 51%
gluster>

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
