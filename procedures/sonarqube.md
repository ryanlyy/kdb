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


