# https://wiki.centos.org/HowTos

# 1. Install needed tools used to build kenel
```
yum install asciidoc audit-libs-devel bash bc binutils binutils-devel bison diffutils elfutils
yum install elfutils-devel elfutils-libelf-devel findutils flex gawk gcc gettext gzip hmaccalc hostname java-devel
yum install m4 make module-init-tools ncurses-devel net-tools newt-devel numactl-devel openssl
yum install patch pciutils-devel perl perl-ExtUtils-Embed pesign python-devel python-docutils redhat-rpm-config
yum install rpm-build sh-utils tar xmlto xz zlib-devel
```
# 2. Login as non-root user and install kenel source code
```
mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros

wget http://vault.centos.org/7.6.1810/updates/Source/SPackages/kernel-3.10.0-957.21.3.el7.src.rpm
rpm -i kernel-3.10.0-957.21.3.el7.src.rpm 2>&1 | grep -v exist
```

# 3. Custom Kerenel
if not customer Kernel Ignore this section
## Modify config file
```
#Update below config file with 'y|m|n'
~/rpmbuild/SOURCES/kernel-$(uname -r|cut -d "-" -f1)-$(uname -m).config
```

## Modify kernel spec file
```
cd ~/rpmbuild/SPECS/
cp kernel.spec kernel.spec.distro
vi kernel.spec
---
# buildid naming update
%define buildid .your_identifier 
---
```
## Kernel Patching
* Generate patch file
```
diff -up /tmp/kernel-3.10.0-862.14.4.el7/net/ipv4/arp.c_org /tmp/kernel-3.10.0-862.14.4.el7/net/ipv4/arp.c >/tmp/arp.patch
```
* Install Patch file
```
cp /tmp/arp.patch /root/rpmbuild/SOURCES/.
```
* Apply patch
  * Locate a line "# empty final patch to facilitate testing of kernel patches"
  * Just after that line add your declaration starting with the number 40000
```
Patch40000: my-custom-kernel.patch
```
  * Locate a line "ApplyOptionalPatch linux-kernel-test.patch"
  * Just before that line, add a line to apply your patch
```
ApplyOptionalPatch my-custom-kernel.patch
```
# 4. Build Kernel
```
cd ~/rpmbuild/SPECS
rpmbuild -bb --target=`uname -m` kernel.spec 2> build-err.log | tee build-out.log
```
# 5. Install Kernel
```
cd  ~/rpmbuild/RPMS/`uname -m`/
su -l 
rpm -ivh kernel-*.rpm
```
