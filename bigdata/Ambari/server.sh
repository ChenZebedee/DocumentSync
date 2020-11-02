#!/bin/bash

# 挂载cdrom

cat << EOF >> /etc/sysconfig/network
# Created by anaconda
NETWORKING=yes
HOSTNAME=$(hostname)
EOF