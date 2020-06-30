# Install EPEL repo
yum -y install epel-release

# PostGreSQL Installation and Configuration
wget https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
rpm -i pgdg-centos96-9.6-3.noarch.rpm 
yum -y install  postgresql-server  postgresql-contrib
```
Initialize the database:
sudo /usr/pgsql-9.6/bin/postgresql96-setup initdb
Edit the /var/lib/pgsql/9.6/data/pg_hba.conf to enable MD5-based authentication.
sudo nano /var/lib/pgsql/9.6/data/pg_hba.conf
Find the following lines and change peer to trust and idnet to md5.
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# "local" is for Unix domain socket connections only
local   all             all                                     peer
# IPv4 local connections:
host    all             all             127.0.0.1/32            ident
# IPv6 local connections:
host    all             all             ::1/128                 ident
Once updated, the configuration should look like the one shown below.
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
```
systemctl start postgresql-9.6
systemctl enable postgresql-9.6
passwd postgres => "postgres"
su - postgres
```
Create a new user by typing:

createuser sonar

Switch to the PostgreSQL shell.

psql

Set a password for the newly created user for SonarQube database.

ALTER USER sonar WITH ENCRYPTED password 'StrongPassword';

Create a new database for PostgreSQL database by running:

CREATE DATABASE sonar OWNER sonar;

Exit from the psql shell:
\q
Switch back to the sudo user by running the exit command
```

# SonarQube Installation and Configuration
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.6.zip
unzip sonarqube-7.6.zip -d /opt
mv /opt/sonarqube-7.6 /opt/sonarqube
vi /opt/sonarqube/cnf/sonar.peroperties
```
Find the following lines.

#sonar.jdbc.username=
#sonar.jdbc.password=

Uncomment and provide the PostgreSQL username and password of the database that we have created earlier. It should look like:

sonar.jdbc.username=sonar
sonar.jdbc.password=StrongPassword

Next, find:

#sonar.jdbc.url=jdbc:postgresql://localhost/sonar

Uncomment the line, save the file and exit from the editor
```
vi /etc/systemd/system/sonar.service
```
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=root
Group=root
Restart=always

[Install]
WantedBy=multi-user.target
```
systemctl start sonar
systemctl enable sonar

# Httpd Configuration
yum -y install httpd
vi /etc/httpd/conf.d/sonar.yourdomain.com.conf
```
Create a new virtual host.

sudo nano /etc/httpd/conf.d/sonar.yourdomain.com.conf

Populate the file with:

<VirtualHost *:80>  
    ServerName sonar.yourdomain.com
    ServerAdmin me@yourdomain.com
    ProxyPreserveHost On
    ProxyPass / http://localhost:9000/
    ProxyPassReverse / http://localhost:9000/
    TransferLog /var/log/httpd/sonar.yourdomain.com_access.log
    ErrorLog /var/log/httpd/sonar.yourdomain.com_error.log
</VirtualHost>
```
sudo systemctl start httpd
sudo systemctl enable httpd

# Don't run sonar as root
```
groupadd sonar
useradd -c "Sonar System User" -d /opt/sonarqube -g sonar -s /bin/bash sonar
chown -R sonar:sonar /opt/sonarqube

edit /opt/sonarqube/bin/sonar.sh – find RUN_AS_USER entry, uncomment it and assign your SonarQube system username:

RUN_AS_USER=sonar
```

# Platform notes - Linux
```
If you're running on Linux, you must ensure that:

    vm.max_map_count is greater or equals to 262144
    fs.file-max is greater or equals to 65536
    the user running SonarQube can open at least 65536 file descriptors
    the user running SonarQube can open at least 2048 threads

You can see the values with the following commands:

sysctl vm.max_map_count
sysctl fs.file-max
ulimit -n
ulimit -u

You can set them dynamically for the current session by running the following commands as root:

sysctl -w vm.max_map_count=262144
sysctl -w fs.file-max=65536
ulimit -n 65536
ulimit -u 2048

To set these values more permanently, you must update either /etc/sysctl.d/99-sonarqube.conf (or /etc/sysctl.conf as you wish) to reflect these values.

If the user running SonarQube (sonarqube in this example) does not have the permission to have at least 65536 open descriptors, you must insert this line in /etc/security/limits.d/99-sonarqube.conf (or /etc/security/limits.conf as you wish):

sonarqube   -   nofile   65536
sonarqube   -   nproc    2048

You can get more detail in the Elasticsearch documentation.

If you are using systemd to start SonarQube, you must specify those limits inside your unit file in the section [service] :

[Service]
...
LimitNOFILE=65536
LimitNPROC=2048
...

seccomp filter

By default, Elasticsearch uses seccomp filter. On most distribution this feature is activated in the kernel, however on distributions like Red Hat Linux 6 this feature is deactivated. If you are using a distribution without this feature and you cannot upgrade to a newer version with seccomp activated, you have to explicitly deactivate this security layer by updating sonar.search.javaAdditionalOpts in $SONARQUBEHOME/conf/sonar.properties_:

sonar.search.javaAdditionalOpts=-Dbootstrap.system_call_filter=false

You can check if seccomp is available on your kernel with:

$ grep SECCOMP /boot/config-$(uname -r)

If your kernel has seccomp, you will see:

CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_SECCOMP=y
```

# SonarScanner Installation and Configuration
export http_proxy=http://135.245.48.34:8000
export https_proxy=https://135.245.48.34:8000
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.3.0.1492-linux.zip
unzip sonar-scanner-cli-3.3.0.1492-linux.zip -d /opt
vi /opt/sonar-scanner-3.3.0.1492-linux/conf/sonar-scanner.properties
```
Uncomment sonar.host.url with correct sonar server url
#----- Default SonarQube server
#sonar.host.url=http://localhost:9000
```

# Build Procedure
```
 /opt/build-wrapper-linux-x86/build-wrapper-linux-x86-64 --out-dir sonar ninja -v  test
```
The sonar report generated by above cmd is stored in "sonar" directory and used by below command: 

/home/developer/ryliu/cci-ntas-new/lcp/ves/build/sonar

```
 /opt/sonar-scanner/bin/sonar-scanner -Dsonar.login="" -Dsonar.sourceEncoding="UTF-8" -Dsonar.projectKey="" -Dsonar.projectName="" -Dsonar.projectVersion="" -Dsonar.projectBaseDir="/home/developer/ryliu/cci-ntas-new/lcp/ves" -Dsonar.branch.name="" -Dsonar.exclusions=**tst**,**/build/**,**/build-test/**,/home/developer/ryliu/cci-ntas-new/lcp/ves/build/**,**.pl -Dsonar.modules=agent,test -Dsonar.cfamily.build-wrapper-output=/home/developer/ryliu/cci-ntas-new/lcp/ves/build/sonar -Dagent.sonar.sources=. -Dagent.sonar.inclusions="**.cpp,**.c,**.hpp,**.h" -Dtest.sonar.modules=agent -Dtest.agent.sonar.sources=. -Dtest.agent.sonar.inclusions="**.cpp,**.c,**.hpp,**.h"
```

# Q&A 
* ERROR: Failure during analysis, Node.js command to start eslint-bridge server was not built yet
```
Need to install nodejs in SonarQube Server
```
* Java heap space error or java.lang.OutOfMemoryError,
```
Increase the memory via the SONAR_SCANNER_OPTS environment variable:
export SONAR_SCANNER_OPTS="-Xmx512m"
```
