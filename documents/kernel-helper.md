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
```
--- a/net/ipv4/arp.c.orig 2019-07-24 03:42:02.652044882 -0400
+++ b/net/ipv4/arp.c      2019-07-24 03:37:27.298044882 -0400
@@ -758,6 +758,11 @@ static bool arp_is_garp(struct net *net,
  *     Process an arp request.
  */

+static int arp_ryanl_test_only()
+{
+       int a = 100;
+       return 1;
+}
 static int arp_process(struct sock *sk, struct sk_buff *skb)
 {
        struct net_device *dev = skb->dev;
@@ -774,11 +779,15 @@ static int arp_process(struct sock *sk,
        struct net *net = dev_net(dev);
        struct dst_entry *reply_dst = NULL;
        bool is_garp = false;
+       int ryanl;

        /* arp_rcv below verifies the ARP header and verifies the device
         * is ARP'able.
         */

+       ryanl = arp_ryanl_test_only();
+       if (ryanl == 10000)
+               goto out;
        if (in_dev == NULL)
                goto out;

```
```
[ryliu@localhost linux-3.10.0-957.21.3.el7.x86_64]$ patch -p1 -F1 -s net/ipv4/arp.c arp_c.patch
```
* Install Patch file
```
cp /tmp/arp.patch /root/rpmbuild/SOURCES/.
```
* Apply patch
  * Locate a line "# empty final patch to facilitate testing of kernel patches", just after that line add your declaration starting with the number 40000
  * Locate a line "ApplyOptionalPatch linux-kernel-test.patch", just before that line, add a line to apply your patch
```
Patch40000: arp.patch
```
```
ApplyOptionalPatch arp.patch
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
