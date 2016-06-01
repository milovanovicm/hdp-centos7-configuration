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
yum install nano -y
ulimit -n 12000

# NTPD
yum install ntp ntpdate ntp-doc -y
systemctl enable ntpd
systemctl start ntpd
# EDIT THE HOSTS FILE
while IFS=' ' read -r line || [[ -n "$line" ]]; do
    echo "$line" >> /etc/hosts
done < ips.txt
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
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