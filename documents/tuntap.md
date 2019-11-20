# tungetiff.gdb
```
[root@foss-ssc-7 scripts]# cat tungetiff.gdb
set $malloc=(void *(*)(long long)) malloc
p $malloc(64)
p memset($1, 0, 64)
p ioctl($fd, 0x800454d2, $1)
set *((char *)($1+15))=0
set logging file /dev/stdout
set logging on
printf "devname=%s\n",$1
printf "devflag(short)_lowbyte=%x\n",*((char *)($1+16))
printf "devflag(short)_highbyte=%x\n",*((char *)($1+17))
set logging off
call free($1)
quit
[root@foss-ssc-7 scripts]#
```

# Attach gdb to executable space
```
gdb </path/to/executable> -batch-silent --pid=<executable_pid> -ex 'set $fd'=<tapdev fd> -x "./tungetiff.gdb"
```

# How to tapdev fd

> ps -ef |grep qemu  |grep fd
```
qemu      2803     1 52 Nov11 ?        4-13:19:24 /usr/libexec/qemu-kvm -name guest=instance-00000024,debug-threads=on -S -object secret,id=masterKey0,format=raw,file=/var/lib/libvirt/qemu/domain-1-instance-00000024/master-key.aes -machine pc-i440fx-rhel7.6.0,accel=kvm,usb=off,dump-guest-core=off -cpu Haswell-noTSX-IBRS,vme=on,ss=on,f16c=on,rdrand=on,hypervisor=on,arat=on,tsc_adjust=on,md-clear=on,stibp=on,ssbd=on,xsaveopt=on,pdpe1gb=on,abm=on -m 32708 -realtime mlock=off -smp 8,sockets=8,cores=1,threads=1 -uuid 8e5e3e56-d4ec-44f5-9363-e3699359ca9b -smbios type=1,manufacturer=RDO,product=OpenStack Compute,version=19.0.3-1.el7,serial=8e5e3e56-d4ec-44f5-9363-e3699359ca9b,uuid=8e5e3e56-d4ec-44f5-9363-e3699359ca9b,family=Virtual Machine -no-user-config -nodefaults -chardev socket,id=charmonitor,fd=26,server,nowait -mon chardev=charmonitor,id=monitor,mode=control -rtc base=utc,driftfix=slew -global kvm-pit.lost_tick_policy=delay -no-hpet -no-shutdown -boot strict=on -device piix3-usb-uhci,id=usb,bus=pci.0,addr=0x1.0x2 -drive file=/var/lib/nova/instances/8e5e3e56-d4ec-44f5-9363-e3699359ca9b/disk,format=qcow2,if=none,id=drive-virtio-disk0,cache=none -device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x4,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1,write-cache=on -drive file=/var/lib/nova/instances/8e5e3e56-d4ec-44f5-9363-e3699359ca9b/disk.config,format=raw,if=none,id=drive-ide0-0-0,readonly=on,cache=none -device ide-cd,bus=ide.0,unit=0,drive=drive-ide0-0-0,id=ide0-0-0,write-cache=on -netdev tap,fd=28,id=hostnet0,vhost=on,vhostfd=30 -device virtio-net-pci,host_mtu=1500,netdev=hostnet0,id=net0,mac=fa:16:3e:1f:a5:21,bus=pci.0,addr=0x3 -add-fd set=3,fd=31 -chardev pty,id=charserial0,logfile=/dev/fdset/3,logappend=on -device isa-serial,chardev=charserial0,id=serial0 -device usb-tablet,id=input0,bus=usb.0,port=1 -vnc 0.0.0.0:0 -device cirrus-vga,id=video0,bus=pci.0,addr=0x2 -device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x5 -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny -msg timestamp=on
```
