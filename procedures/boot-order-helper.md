https://wiki.centos.org/HowTos/Grub2

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
