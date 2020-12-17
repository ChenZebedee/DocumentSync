#!/bin/bash

#jdk安装,卸载默认
auto_replice_java(){
    yum remove "*openjdk*" -y
    mkdir /opt/binary
    tar zxf jdk-8u181-linux-x64.tar.gz -C /opt/binary
    ln -s /opt/binary/jdk1.8.0_181 /usr/local/java
    cat << EOF >> /etc/profile
#JAVA_HOME
export JAVA_HOME=/usr/local/java
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=.:\$JAVA_HOME/lib:\$JRE_HOME/lib
export PATH=\${PATH}:\${JAVA_HOME}/bin
EOF
}

var_config(){
    ip_list=()
    host_name=()
    passwd=""
    now_pc_index=""
    work_dir=""
}

hosts_config(){
    index=0
    for index in `seq 0 ${#ip_list[*]}`
    do
        echo "${ip_list[${index}]} ${host_name[${index}]}" >> /etc/hosts
    done
    echo "host设置完成"
}

set_host_name(){
    hostnamectl set-hostname --static ${host_name[${now_pc_index}]}
    if [ `hostname` == ${host_name[${now_pc_index}]} ]
    then
        echo "host_name set success"
    else
        echo "Please retry manually"
    fi
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
        echo "selinux 停止成功"
    fi
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

    #for ip in $(cat /etc/hosts | grep -v localhost | awk '{print $2}'); do
    for index in `seq 0 ${#host_name[*]}`;
    do
        ssh_expect ${host_name[${index}]} $passwd
    done
}

oracle_user_ssh_no_passwd(){
    su - oracle -s /bin/bash oracle_user_ssh_no_passwd.sh
    
    var_config

    auto_copy_ssh_id
}

oracle_profile_add(){
    su - oracle -s /bin/bash oracle_profile_add.sh

}