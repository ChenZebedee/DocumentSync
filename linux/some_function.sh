#!/bin/bash

echo -n "local_host_name:"
read local_host_name

#配置处
var_config(){
    ip_list=()
    host_name=()
    passwd=""
    now_pc_index=""
    work_dir=""
    source_dir=""
}

#根据内容获取数组下标
get_array_index(){
    for i in `seq `
}

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

#ssh自动配置 $1为ip或者hosts里面对应主机名  $2为用户密码
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

    #for ip in $(cat /etc/hosts | grep -v localhost | awk '{print $2}'); do
    for index in `seq 0 ${#host_name[*]}`;
    do
        ssh_expect ${host_name[${index}]} $passwd
    done
}

#jdk安装,卸载默认
auto_replice_java(){
    yum remove "*openjdk*" -y
    mkdir /opt/binary
    tar zxf ${java_path} -C /opt/binary
    ln -s /opt/binary/jdk1.8.0_181 /usr/local/java
    cat << EOF >> /etc/profile
#JAVA_HOME
export JAVA_HOME=/usr/local/java
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib
export PATH=\${PATH}:\${JAVA_HOME}/bin
EOF
}


#hosts文件配置
hosts_config(){
    index=0
    for index in `seq 0 ${#ip_list[*]}`
    do
        echo "${ip_list[${index}]} ${host_name[${index}]}" >> /etc/hosts
    done
    echo "host设置完成"
}

#hostName设置
set_host_name(){
    hostnamectl set-hostname --static ${host_name[${now_pc_index}]}
    if [ `hostname` == ${host_name[${now_pc_index}]} ]
    then
        echo "host_name set success"
    else
        echo "Please retry manually"
    fi
}

#关闭防火墙
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

#关闭selinux
selinux_stop(){
    selinux_status=`getenforce`
    if [ "${selinux_status}" == "Enforcing" ]
    then
        setenforce 0
        sed 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config -i
        echo "selinux 停止成功"
    fi
}


create_user(){

}

create_group(){
    result=""
    egrep "^$2" /etc/group >& /dev/null
    if [ $? -ne 0 ]
    then
        groupadd -g $1 $2
        result="group add success"
    else
        result="is exist"
    fi
    echo ${result}
}

create_user(){
    result=""
    egrep "^$2" /etc/passwd >& /dev/null
    if [ $? -ne 0 ]
    then
        useradd -g $1 $2
        result="user add success"
    else
        result="is exist"
    fi
    echo ${result}
}

user_add_group(){
    result=""
    groups $2 | egrep $1 >& >/dev/null
    if [ $? -ne 0 ]
    then
        usermode -a -G $1 $2
        result="user add group success"
    else
        result="is exist"
    fi
    echo ${result}
}


create_orcle_user(){
    create_group 500 oinstall
    create_group 501 dba
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

#kafka install
auto_install_kafka(){
}

#zookeeper install
auto_install_zookeeper(){
    tar zxf zookeeper-3.4.6.tar.gz -C ${source_dir}
    mv ${source_dir}/zookeeper-3.4.6 ${source_dir}/zookeeper
    #cp ${source_dir}/zookeeper/conf/zoo_sample.cfg ${source_dir}/zookeeper/conf/zoo.cfg
    mkdir ${source_dir}/zookeeper/data

    cat << EOF > ${source_dir}/zookeeper/conf/zoo.cfg
# The number of milliseconds of each tick
tickTime=2000
# The number of ticks that the initial
# synchronization phase can take
initLimit=10
# The number of ticks that can pass between
# sending a request and getting an acknowledgement
syncLimit=5
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just
# example sakes.
dataDir=${source_dir}/zookeeper/data
# the port at which the clients will connect
clientPort=2181
forceSync=no
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1

server.1= ${IP01}:2888:3888
server.2= ${IP02):2888:3888
server.3= ${IP03}:2888:3888
EOF
}


