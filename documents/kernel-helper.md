# 1. Install needed tools used to build kenel
```
[root@host]# yum install asciidoc audit-libs-devel bash bc binutils binutils-devel bison diffutils elfutils
[root@host]# yum install elfutils-devel elfutils-libelf-devel findutils flex gawk gcc gettext gzip hmaccalc hostname java-devel
[root@host]# yum install m4 make module-init-tools ncurses-devel net-tools newt-devel numactl-devel openssl
[root@host]# yum install patch pciutils-devel perl perl-ExtUtils-Embed pesign python-devel python-docutils redhat-rpm-config
[root@host]# yum install rpm-build sh-utils tar xmlto xz zlib-devel
```
# 2. Login as non-root user and install kenel source code
```
[user@host]$ mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
[user@host]$ echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

wget http://vault.centos.org/7.6.1810/updates/Source/SPackages/kernel-3.10.0-957.21.3.el7.src.rpm
rpm -i kernel-3.10.0-957.21.3.el7.src.rpm 2>&1 | grep -v exist

[user@host]$ cd ~/rpmbuild/SPECS
[user@host SPECS]$ rpmbuild -bp --target=$(uname -m) kernel.spec

```


