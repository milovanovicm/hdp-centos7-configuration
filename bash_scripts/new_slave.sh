#!/bin/bash
<<'COMMENT'
@params
:input new_ip.txt file containing the following info for new hosts:

my.host.name.1 host1_ip_address
my.host.name.2 host2_ip_address

Description:
This script should be run when adding a new slave to a cluster.
The script should be run on master node within a cluster.

The script adds a new host to a master.
You must be logged in as a root user on a host.
COMMENT

# Passwordless login master -> slave
while IFS=' ' read -r var1 var2
do
    ssh root@"$var1" mkdir -p .ssh
    cat .ssh/id_rsa.pub | ssh root@"$var1" 'cat >> .ssh/authorized_keys'
done < new_ip.txt

# Add new host to the list of known hosts
while IFS=' ' read -r line || [[ -n "$line" ]]; do
    echo "$line" >> /etc/hosts
done < new_ips.txt