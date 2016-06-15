#!/bin/bash
<<'COMMENT'
@params
:input ips.txt file containing the following info for all the hosts in a cluster:

my.host.name.1 host1_ip_address
my.host.name.2 host2_ip_address

Description:
This script should be run when configuring a master node for a cluster.
The script should be run on master node within a cluster.

You must be logged in as a root user on a host.
COMMENT

# Disable yum fastestmirror
sed -n -i '/enabled=1/!p' /etc/yum/pluginconf.d/fastestmirror.conf
echo enabled=0 >> /etc/yum/pluginconf.d/fastestmirror.conf

# Proxy configuration
echo http_proxy=proxy.fon.rs:8080 >> /etc/environment
echo http_proxy=proxy.fon.rs:8080 >> /etc/yum.conf
export http_proxy=proxy.fon.rs:8080

# Install required packages
cd ~
mkdir /home/hadoop
yum install unzip -y
yum install wget -y
ulimit -n 12000

# Install Java - jre8u60
cd ~
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
"http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jre-8u60-linux-x64.rpm"
sudo yum localinstall jre-8u60-linux-x64.rpm
rm ~/jre-8u60-linux-x64.rpm

# Passwordless login master -> slaves
cd ~
ssh-keygen
# scp public key to remote (slave) hosts
while IFS=' ' read -r var1 var2
do
    ssh root@"$var1" 'mkdir -p .ssh'
    cat .ssh/id_rsa.pub | ssh root@"$var1" 'cat >> .ssh/authorized_keys'
done < ips.txt

# Enable ntpd
yum install ntp ntpdate ntp-doc -y
systemctl enable ntpd
systemctl start ntpd
service start ntpd

# Populate known hosts within a cluster
while IFS=' ' read -r line || [[ -n "$line" ]]; do
    echo "$line" >> /etc/hosts
done < ips.txt

# Disable firewall (previously iptables) - by default disabled in Centos 7 Minimal version
# systemctl disable firewalld
# service firewalld stop

# Disable SELINUX
setenforce 0
sed -n -i '/SELINUX=enforcing/!p' /etc/selinux/config
echo SELINUX=disabled >> /etc/selinux/config

# Umask settings
umask 0022
echo umask 0022 >> /etc/profile

# Obtain Ambari repo for automated install - Ambari 2.2.2.0
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.2.0/ambari.repo -O /etc/yum.repos.d/ambari.repo

# Symbolic link to HDFS storage
ln -s /home /data