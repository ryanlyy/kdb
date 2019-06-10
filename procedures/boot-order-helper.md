https://wiki.centos.org/HowTos/Grub2

# Generate boot order configuration file
[root@foss-ssc-9 boot]# cat  /etc/default/grub
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_SAVEDEFAULT=true
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet"
GRUB_DISABLE_RECOVERY="true"
[root@foss-ssc-9 boot]#

**Compare /etc/grub2.cfg and /boot/grub2/grub.cfg**
grub2-mkconfig -o /etc/grub2.cfg
grub2-mkconfig -o /boot/grub2/grub.cfg

# To list all the menu entries that will be displayed at system boot, issue the following command: 
```
[root@foss-ssc-7 ~]# awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
0 : CentOS Linux (4.4.39-1.el7.elrepo.x86_64) 7 (Core)
1 : CentOS Linux (3.10.0-693.21.1.el7.x86_64) 7 (Core)
2 : CentOS Linux (3.10.0-327.36.3.el7.x86_64) 7 (Core)
3 : CentOS Linux (3.10.0-327.el7.x86_64) 7 (Core)
4 : CentOS Linux (0-rescue-82946adf21344a15967af4e214e3fd65) 7 (Core)
```
# Default boot entry
```
The default entry is defined by the GRUB_DEFAULT line in the /etc/default/grub file. However, if the GRUB_DEFAULT line is set as saved, the parameter is stored in the /boot/grub2/grubenv file. It may be viewed by:

[root@host ~]# grub2-editenv list
saved_entry=CentOS Linux (3.10.0-229.14.1.el7.x86_64) 7 (Core)
```

# Set Default Entry
```
The /boot/grub2/grubenv file cannot be manually edited. Use the following command instead:

[root@host ~]# grub2-set-default 2
[root@host ~]# grub2-editenv list
saved_entry=2
```
