#!/bin/bash

ip_list=()
host_name=()
ods_dir="/home/u01"


hosts_config(){
    index=0
    for index in `seq 0 ${#ip_list[*]}`
    do
        echo "${ip_list[${index}]} ${host_name[${index}]}" >> /etc/hosts
    done
}


firewall_stop(){
    FIREWALLD=`systemctl status firewalld | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1`
    if [ "$FIREWALLD" == "running" ]
    then
        systemctl stop firewalld
        echo "停止成功"
        systemctl disable firewalld
        echo "自启动关闭成功"
    else
        echo "已停止"
    fi
}

selinux_stop(){
    selinux_status=`getenforce`
    if [ "${selinux_status}" == "Enforcing" ]
    then
        setenforce 0
        sed 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config -i
    fi
}

create_orcle_user(){
    groupadd -g 500 oinstall
    groupadd -g 501 dba
    useradd -g 500 -G 501 -d /home/oracle oracle

    expect -c "set timeout -1;
    passwd oracle

    expect {
        "password:" { send -- oracle\r;exp_continue;}
        eof
    }"
}

create_ods_orcle_dir(){
    mkdir -p ${ods_dir}
    chown -R oracle:oinstall ${ods_dir}
    cat << EOF >/home/oracle/.bash_profile
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH

export ORACLE_BASE=${ods_dir}
export ORACLE_HOME=$ORACLE_BASE/app/product/12.2.0/db_1
export ORACLE_SID=ods
export NLS_DATE_FORMAT="yyyy-mm-dd hh24:mi:ss"
export NLS_LANG=AMERICAN_AMERICA.zhs16gbk
export PATH=.:${PATH}:$HOME/bin:$ORACLE_HOME/bin
export PATH=${PATH}:/usr/bin:/bin:/usr/bin/X11:/usr/local/bin
export PATH=${PATH}:$ORACLE_BASE/common/oracle/bin
export ORACLE_PATH=${PATH}:$ORACLE_BASE/common/oracle/sql:.:$ORACLE_HOME/rdbms/admin
export ORACLE_TERM=xterm
export TNS_ADMIN=$ORACLE_HOME/network/admin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$ORACLE_HOME/oracm/lib
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/lib:/usr/lib:/usr/local/lib
export CLASSPATH=$ORACLE_HOME/JRE
export CLASSPATH=${CLASSPATH}:$ORACLE_HOME/jlib
export CLASSPATH=${CLASSPATH}:$ORACLE_HOME/rdbms/jlib
export CLASSPATH=${CLASSPATH}:$ORACLE_HOME/network/jlib
export TEMP=/tmp
export TMPDIR=/tmp
EOF
    chown oracle:oinstall /home/oracle/.bash_profile
}



#无网挂载cdrom
mount_cdrpm() {
    mkdir -p /cdbase
    #mount /dev/cdrom /cdbase/
    mount -o loop /home/ec.iso /iso
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

ssh_expect() {
    expect -c "set timeout -1;
    spawn ssh-copy-id -f $1

    expect {
        "yes/no" { send -- yes\r;exp_continue;}
        "password:" { send -- $2\r;exp_continue;}
        eof
    }"
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

auto_install_expect

hosts_config

firewall_stop

selinux_stop

create_orcle_user

create_ods_orcle_dir