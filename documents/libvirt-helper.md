# libvirtd Default Network
```
[root@test-96-b libvirt]# cat /etc/libvirt/qemu/networks/default.xml
<!--
WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
OVERWRITTEN AND LOST. Changes to this xml configuration should be made using:
  virsh net-edit default
or other application using the libvirt API.
-->

<network>
  <name>default</name>
  <uuid>4456461a-0e84-46b5-baed-1fe03d18fea9</uuid>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:06:7b:2a'/>
  <ip address='192.168.96.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.96.2' end='192.168.96.254'/>
    </dhcp>
  </ip>
</network>
```

# How to change default network
```
virsh net-destory default
<change above configure>
virsh net-start default 
<to check if network id correct>
virsh net-edit default 
```
