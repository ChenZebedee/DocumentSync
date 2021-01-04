#!/bin/bash


#配置处
ip_list=(172.17.88.164 172.17.88.165 172.17.88.160 172.17.88.161 172.17.88.162)
host_name=(ods cdr kafka1 kafka2 kafka3)
passwd="oracle"
now_pc_index=2
work_dir="/home/app"
source_dir="/home/soft"
java_path=${source_dir}/jdk-8u181-linux-x64.tar.gz
iso_file=ec.iso
ods_dir=${work_dir}/
now_host_name=${host_name[${now_pc_index}]}
page_tile="宿迁市第一人民医院"

#kafka 集群 ip 配置
IP01=172.17.88.160
IP02=172.17.88.161
IP03=172.17.88.162
# 当前kafka节点
now_kafka_index=1



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

#文件挂载filename
file_to_mount_cdrpm(){
    mount -t iso9660 -O loop  ${source_dir}/${iso_file} /mnt
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
    echo ${now_host_name}
    hostnamectl set-hostname --static ${now_host_name}
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
    groups $2 | egrep $1 >& /dev/null
    if [ $? -ne 0 ]
    then
        usermode -a -G $1 $2
        result="user add group success"
    else
        result="is exist"
    fi
    echo ${result}
}


create_oracle_user(){
    create_group 500 oinstall
    create_group 501 dba
    useradd -g 500 -G 501 -d /home/oracle oracle

    expect -c "set timeout -1;
     spawn passwd oracle

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
    tar zxf ${source_dir}/kafka_2.12-2.0.0.tgz -C ${work_dir}
    mv ${work_dir}/kafka_2.12-2.0.0 ${work_dir}/kafka

    cat << EOF > ${work_dir}/kafka/config/server.properties
broker.id=${now_kafka_index}
host.name=${ip_list[now_pc_index]}
port=9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=${work_dir}/kafka/data
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=3
transaction.state.log.replication.factor=3
transaction.state.log.min.isr=3
log.retention.hours=168
default.replication.factor=3
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect= ${IP01}:2181,${IP02}:2181,${IP03}:2181
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0

group.min.session.timeout.ms=6000
group.max.session.timeout.ms=1000000
delete.topic.enable=true
EOF

}

#zookeeper install
auto_install_zookeeper(){
    tar zxf ${source_dir}/zookeeper-3.4.6.tar.gz -C ${work_dir}
    mv ${work_dir}/zookeeper-3.4.6 ${work_dir}/zookeeper
    mkdir ${work_dir}/zookeeper/data

    cat << EOF > ${work_dir}/zookeeper/conf/zoo.cfg
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
dataDir=${work_dir}/zookeeper/data
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
server.2= ${IP02}:2888:3888
server.3= ${IP03}:2888:3888
EOF
    echo ${now_kafka_index} > ${work_dir}/zookeeper/data/myid
}

kafka_oracle_bash_profile_config(){
    cat << EOF > ~/.bash_profile
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=\$PATH:\$HOME/.local/bin:\$HOME/bin

export PATH

export ZOOKEEPER_HOME=${work_dir}/zookeeper
export KAFKA_HOME=${work_dir}/kafka
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$ZOOKEEPER_HOME/lib:\$KAFKA_HOME/libs:\$CLASSPATH
export PATH=\$JAVA_HOME/bin:\$KAFKA_HOME/bin:\$ZOOKEEPER_HOME/bin:\$PATH
export OGG_HOME=${work_dir}/bigdata-base/ogg
export PATH=\$JAVA_HOME/bin:\$OGG_HOME:\$PATH
export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:\$OGG_HOME:\$JAVA_HOME/jre/lib/amd64/libjsig.so:\$JAVA_HOME/jre/lib/amd64/server/libjvm.so:\$JAVA_HOME/jre/lib/amd64/server:\$JAVA_HOME/jre/lib/amd64

EOF
}

ogg_add_kafka_config(){
    cat << EOF > ${work_dir}/bigdata-base/ogg/dirprm/custom_kafka_producer.properties
bootstrap.servers=${IP01}:9092,$IP02:9092,$IP03:9092
acks=1
compression.type=gzip
reconnect.backoff.ms=1000

value.serializer=org.apache.kafka.common.serialization.ByteArraySerializer
key.serializer=org.apache.kafka.common.serialization.ByteArraySerializer
# 100KB per partition
batch.size=102400
linger.ms=10000

max.request.size = 30096000
send.buffer.bytes = 30096000
EOF
}


config_bigdata_base_application(){
    cat << EOF > ${work_dir}/bigdata-base/application.yml
datatools:
  ip: $IP01   #当前所在主机IP
  name: 大数据管理平台目标端
  remark: 大数据管理平台目标端

#引擎包访问地址
engine:
  address: http://$IP02:8095

#ETL项目访问地址
etl:
  address: http://$IP03:8098

#配置小程序（中转器）访问地址
operation:
  address: http://小程序ip:9683

spring:
  datasource:    #大数据管理平台数据库环境
    url: jdbc:oracle:thin:@//$(cat /etc/hosts | grep ods |awk '{printf $1}'):1521/odspdb
    username: datatools
    password: oracle
kafka:
  server:
    home: /data/app/kafka    #kafka安装路径
    replications: 3    #kafka副本数，与kafka集群节点数一致
  consumer:
    bootstrap.servers: $IP01:9092,$IP02:9092,$IP03:9092   # kafka集群
zookeeper:
  quorum: $IP01:2181,$IP02:2181,$IP03:2181   #zookeeper集群

#表附加开关 0关 1开
trandata:
  flag: 1
#ogg安装路径和端口(默认路径和端口)
ogg:
  path: ../datatools/ogg
  port: 7809
#进程配置是否添加默认字段(op_type和last_update_time) 0 关 1开
sourceTrace:
flag: 0
EOF
}


engine_bigdata_config_application(){
    cat << EOF > ${work_dir}/bigdata-engine/application.yml
server:
  ip: $IP01 #当前所在主机IP
  name: 大数据管理平台目标端engine
  remark: 大数据管理平台目标端engine
base: # base包url
  address: http://$IP01:8096

spring:
  datasource:    #大数据管理平台数据库环境
    driver-class-name: oracle.jdbc.driver.OracleDriver
      #    url: jdbc:oracle:thin:@//192.168.140.88:1521/orclpdb
      #    username: datatools240
      #    password: 123456
    url: jdbc:oracle:thin:@//$(cat /etc/hosts | grep ods |awk '{printf $1}'):1521/odspdb
    username: datatools
    password: oracle
kafka:
  server:
    replications: 3    #kafka副本数，与kafka集群节点数一致
  consumer:
    bootstrap.servers: $IP01:9092,$IP02:9092,$IP03:9092   # kafka集群
zookeeper:
  quorum: $IP01:2181,$IP02:2181,$IP03:2181   #zookeeper集群


ogg:
  lag:
    warning: 1800
EOF
}

auto_install_nginx(){
    yum install gcc-c++ pcre pcre-devel  zlib zlib-devel openssl openssl--devel  -y
    mkdir ${work_dir}/nginx
    tar zxf ${source_dir}/nginx-1.9.14.tar.gz -C ${work_dir}/nginx
    cd ${work_dir}/nginx/nginx-1.9.14
    ./configure
    make && make install
    cat << EOF > /usr/local/nginx/conf/nginx.conf
user  root;
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

server {
        listen       8082; #监听端口 客户端
        server_name  $IP01; #监听地址 #域名
                keepalive_requests 120; #单连接请求上限次数。
        location / {
            try_files \$uri \$uri/ /index.html;
            root   ${work_dir}/pages/tool-manager; #前端项目目录
            index  index.html index.htm; #设置默认页
        }
}
}
EOF
}

config_tool_manager(){
    unzip -d ${work_dir}/pages ${source_dir}/tool-manager.zip
    cat << EOF > ${work_dir}/pages/tool-manager/config.js
(function() {
  window.DataConfig = {

    axios: 'http://${IP01}:8096', // 目标端地址
    title: '${page_tile}',
    logo: '/logo.png', // 项目logo

    isAccessSystem: true, // 是否切换系统
    homeHref: '#', // 切换系统之后跳转到的主页面
    menuUrlList: [
      {
        url: 'ewell.home.level', //首页
        urlReal: '/homepage',
      },
      {
        url: 'ewell.operationhome.level', //运维首页
        urlReal: '/operationhome',
      },
      {
        url: 'ewell.assetshome.level', //资产首页
        urlReal: '/assetshome',
      },
      {
        url: 'ewell.datasources.level', //数据源管理
        urlReal: '/dataSource',
      },
      {
        url: 'ewell.datasources.manufacturer', //数据源管理-厂商管理
        urlReal: '/dataSource/factoryManagement',
      },
      {
        url: 'ewell.datasources.businesssystem', //数据源管理-生成系统
        urlReal: '/dataSource/productionSystem',
      },
      {
        url: 'ewell.datasources.systemhost', //数据源管理-服务器管理
        urlReal: '/dataSource/serverManagement',
      },
      {
        url: 'ewell.datasources.database', //数据源管理-数据库
        urlReal: '/dataSource/databaseManagement',
      },
      {
        url: 'ewell.datasources.tableinfo', //数据源管理-数据表
        urlReal: '/dataSource/databaseTables',
      },
      {
        url: 'ewell.datasources.tableorview', //数据源管理-视图管理
        urlReal: '/dataSource/viewManagement',
      },
      {
        url: 'ewell.datasources.database.user', //数据源管理-数据用户管理
        urlReal: '/dataSource/dataUserManagement',
      },
      {
        url: 'ewell.datahandle.level', //数据处理
        urlReal: '/linkManage1',
      },
      {
        url: 'ewell.datahandle.linkmanage', //数据处理-数据引擎
        urlReal: '/linkManage',
      },
      {
        url: 'ewell.datahandle.etlwork', //数据处理-ETL作业
        urlReal: '/pageConfig/etlWork',
      },
      {
        url: 'ewell.datahandle.datacomparenew', //数据处理-数据效验
        urlReal: '/dataCompareNew',
      },
      {
        url: 'ewell.datagovernment.level', //数据治理
        urlReal: '/dataCheck',
      },
      {
        url: 'ewell.dataassets.level', //数据资产
        urlReal: '/assetsDisplay',
      },
      {
        url: 'ewell.dataassets.tablestructure', //数据资产-资产概览
        urlReal: '/assetsDisplay/dataOverview',
      },
      {
        url: 'ewell.dataassets.platcharts', //数据资产-模型管理
        urlReal: '/dataManager/tableStructure/detail',
      },
      {
        url: 'ewell.dataassets.datastatistics', //数据资产-资产报表
        urlReal: '/dataStatistics/showData',
      },
      {
        url: 'ewell.dataassets.datastatistics.dataconfig', //数据资产-报表配置
        urlReal: '/dataStatistics/dataConfig',
      },
      {
        url: 'ewell.dataassets.casedocument', //数据资产-病历文书
        urlReal: '/pageConfig/caseDocument',
      },
      {
        url: 'ewell.dataservice.level', //数据服务
        urlReal: '/dataService',
      },
      {
        url: 'ewell.dataservice.datarelation', //数据服务-数据服务
        urlReal: '/dataService/list',
      },
      {
        url: 'ewell.dataservice.datacheck', //数据服务-数据查阅
        urlReal: '/dataService/inquire',
      },
      {
        url: 'ewell.explorer.level', //互联互通
        urlReal: '/docManage',
      },
      {
        url: 'ewell.explorer.docmanage.empi', //互联互通-患者主索引
        urlReal: '/docManage/empi',
      },
      {
        url: 'ewell.explorer.docmanage.filesshare', //互联互通-共享文档
        urlReal: '/docManage/filesShare',
      },
      {
        url: 'ewell.explorer.docmanage.standardmanage', //互联互通-标准管理
        urlReal: '/docManage/standardManage',
      },
      {
        url: 'ewell.explorer.docmanage.filesbrowse', //互联互通-文档浏览
        urlReal: '/docManage/filesBrowse',
      },
      {
        url: 'ewell.explorer.dataquality', //互联互通-数据质量
        urlReal: '/pageConfig/dataQuality',
      },
      {
        url: 'ewell.platform.level', //平台管理
        urlReal: '/pageConfig',
      },
      {
        url: 'ewell.platform.casedocument', //角色管理
        urlReal: '/pageConfig/authority',
      },
      {
        url: 'ewell.platform.userconfig', //平台管理-用户管理
        urlReal: '/pageConfig/template',
      },
      {
        url: 'ewell.platform.datajurisdiction', //平台管理-数据权限管理
        urlReal: '/pageConfig/dataAuthorityManagement',
      },
      {
        url: 'ewell.platform.approval', //平台管理-我的任务
        urlReal: '/pageConfig/myTask',
      },
      {
        url: 'ewell.platform.msgconfig', //平台管理-短信配置
        urlReal: '/pageConfig/messageConfig',
      },
      {
        url: 'ewell.platform.modulesconfig', //平台管理-业务域管理
        urlReal: '/pageConfig/modulesConfig',
      },
      {
        url: 'ewell.platform.homepageconfig', //平台管理-运维配置
        urlReal: '/pageConfig/homepageConfig',
      },
      {
        url: 'ewell.platform.taskschedul', //平台管理-任务调度
        urlReal: '/taskSchedul',
      },
      {
        url: 'ewell.platform.datalog', //平台管理-运行日志
        urlReal: '/log',
      },
      {
        url: 'ewell.platform.kafkaconsumer', //平台管理-kafka消费
        urlReal: '/pageConfig/kafkaConsumer',
      },
      {
        url: 'ewell.platform.columnMonitor', //平台管理-数据监测
        urlReal: '/pageConfig/columnMonitor',
      },
      {
        url: 'ewell.platform.processConfig', //平台管理-通用进程
        urlReal: '/pageConfig/processConfig',
      },
      {
        url: 'ewell.abouthelp.level', //关于平台
        urlReal: '/pageConfig/aboutPage',
      },
    ],
  };
  window.PageConfig = {
    authority: true, //权限开关
    axios: 'http://192.168.140.151:8080/explorer/',
    authorityHerf: 'http://60.191.39.142:7096/authorityManagement/login', //权限地址
    showEmpi: true, //是否显示文档管理> 患者主索引
    showShare: true, // 是否显示文档管理> 文档共享
    showFilesCheck: true, //是否显示 文档管理 > 患者主索引 > 文档共享调阅
    filesCheckWithInterfaces: true, //进入共享文档调阅时,是否要请求接口.
    filesCheckBaseURL:
      'http://10.95.18.29:8090/phip-web/docForPerson/view/documentList?orgCode=350211A1002&idNo=', //文档共享调阅地
  };
})();
EOF

}

chown_work_dir_as_oracle(){
    chown -R oracle:oinstall ${work_dir}
}

config_systemc_limit(){
    cat << EOF >> /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft nproc unlimited
* hard nproc unlimited
oracle soft nproc 16384
oracle hard nproc 60240
oracle soft nofile 4096
oracle hard nofile 65536
EOF


sed 's#4096#unlimited#g' /etc/security/limits.d/20-nproc.conf -i
cat << EOF >> /etc/security/limits.d/20-nproc.conf
oracle     soft    nproc     65535
EOF

}




