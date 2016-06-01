#!/bin/bash
# SET PROXY
echo http_proxy=proxy.fon.rs:8080 >> /etc/environment
echo http_proxy=proxy.fon.rs:8080 >> /etc/yum.conf
export http_proxy=proxy.fon.rs:8080

# Install required packages
cd ~
mkdir /home/hadoop
yum install unzip -y
yum install wget -y
ulimit -n 12000

# Passwordless
ssh-keygen
# SCP KEYGEN
while IFS=' ' read -r var1 var2
do
    ssh root@"$var1" mkdir -p .ssh
    cat .ssh/id_rsa.pub | ssh root@"$var1" 'cat >> .ssh/authorized_keys'
done < ips.txt

# NTPD
yum install ntp ntpdate ntp-doc -y
systemctl enable ntpd
systemctl start ntpd
# EDIT THE HOSTS FILE
while IFS=' ' read -r line || [[ -n "$line" ]]; do
    echo "$line" >> /etc/hosts
done < ips.txt
# 1.4.4.3. Edit the Network Configuration File
# systemctl disable firewalld
# service firewalld stop

# Disable SELINUX
setenforce 0
sed -n -i '/SELINUX=enforcing/!p' /etc/selinux/config
echo SELINUX=disabled >> /etc/selinux/config

# Umask
umask 0022
echo umask 0022 >> /etc/profile

# Obtain Ambari repo -- MASTER ONLY
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.2.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
