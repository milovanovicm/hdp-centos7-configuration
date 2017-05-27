#!/bin/bash
<<'COMMENT'
@params
:input ips.txt file containing the following info for all the hosts in a cluster:

my.host.name.1 host1_ip_address
my.host.name.2 host2_ip_address

Description:
This script should be run when configuring slave nodes for a cluster.
The script should be run on each of the slave nodes within a cluster.

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
mkdir /home/hadoop
yum install unzip -y
yum install wget -y
yum install nano -y
ulimit -n 12000

echo '*   hard    nofile  12000' >> /etc/security/limits.conf
echo '*   soft    nofile  12000' >> /etc/security/limits.conf

# Disable ntpd
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

# Change pub key permissions
mkdir .ssh
cat id_rsa.pub >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Disable SELINUX
setenforce 0
sed -n -i '/SELINUX=enforcing/!p' /etc/selinux/config
echo SELINUX=disabled >> /etc/selinux/config

# Umask settings
umask 0022
echo umask 0022 >> /etc/profile

# Symbolic link to HDFS storage
ln -s /home /data