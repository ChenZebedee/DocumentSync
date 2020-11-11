#!/bin/bash

#无网挂载cdrom
mount_cdrpm() {
    mkdir -p /cdbase
    mount /dev/cdrom /cdbase/
    mkdir /etc/yum.repos.d/bak
    mv /etc/yum.repos.d/* /etc/yum.repos.d/bak/
    cat <<EOF >/etc/yum.repos.d/CentOS-Media.repo
# CentOS-Media.repo
#
#  This repo can be used with mounted DVD media, verify the mount point for
#  CentOS-7.  You can use this repo and yum to install items directly off the
#  DVD ISO that we release.
#
# To use this repo, put in your DVD and use it with the other repos too:
#  yum --enablerepo=c7-media [command]
#  
# or for ONLY the media repo, do this:
#
#  yum --disablerepo=\* --enablerepo=c7-media [command]

[c7-media]
name=CentOS-$releasever - Media
baseurl=file:///cdbase
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF

}

ssh_expect() {
    expect -c "set timeout -1;
    spawn ssh-copy-id -f $1

    expect {
        "yes/no" { send -- yes\r;exp_continue;}
        "password:" { send -- $2\r;exp_continue;}
        eof
    }"
}

#判断是否有 expect 没有就安装
auto_install_expect() {
    if ! rpm -q expect >/dev/null; then
        echo "###expect 未安装，现在安装###"
        yum install -y expect &>/dev/null
        if [ $? -ne 0 ]; then
            echo "###expect 安装失败###"
            exit 1
        fi
    fi
}

#本机没有SSH密钥则生成
auto_create_ssh_key() {
    if [ ! -f ~/.ssh/id_rsa ]; then
        echo "###请按3次enter键###"
        ssh-keygen -t rsa
    fi
}

#批量实现SSH免密登录
#使用前先配置/etc/hosts文件
auto_copy_ssh_id() {

    auto_install_expect

    auto_create_ssh_key

    passwd="xcwjj#888"

    for ip in $(cat /etc/hosts | grep -v localhost | awk '{print $2}'); do
        ssh_expect $ip $passwd
    done
}

mount_cdrpm
auto_copy_ssh_id
