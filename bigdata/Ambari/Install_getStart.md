<!-- TOC -->

- [安装前准备](#安装前准备)
    - [1. 安装JDK1.8](#1-安装jdk18)
        - [卸载openjdk](#卸载openjdk)
        - [下载](#下载)
            - [tar包安装方式(.tar.gz)](#tar包安装方式targz)
        - [rpm包安装方式(.rpm)](#rpm包安装方式rpm)
    - [2. 系统要求](#2-系统要求)
        - [2.1 系统软件要求](#21-系统软件要求)
        - [2.2 内存要求](#22-内存要求)
        - [2.3 包大小和节点数](#23-包大小和节点数)
        - [2.4 最大打开文件数](#24-最大打开文件数)
            - [查看命令](#查看命令)
            - [配置教程](#配置教程)
    - [3. 信息收集](#3-信息收集)
    - [4. 安装之前准备工作](#4-安装之前准备工作)
        - [4.1 免密登陆配置](#41-免密登陆配置)
        - [4.2用户权限控制](#42用户权限控制)
        - [4.3NTP配置(有点问题，之后再看)](#43ntp配置有点问题之后再看)
        - [4.4 DNS 和 NSCD配置](#44-dns-和-nscd配置)
            - [hosts file](#hosts-file)
            - [hostname](#hostname)
            - [网络配置](#网络配置)
        - [4.5 防火墙配置](#45-防火墙配置)
        - [4.6 selinux配置](#46-selinux配置)
        - [4.7 数据库配置](#47-数据库配置)
            - [MySQL配置](#mysql配置)
            - [PostgreSQL配置(略)](#postgresql配置略)
            - [Oracle 配置(略)](#oracle-配置略)
        - [4.8 数据库安装](#48-数据库安装)
            - [MySQL](#mysql)
            - [PostgreSQL(略)](#postgresql略)
            - [Oracle(略)](#oracle略)
- [本地源安装](#本地源安装)
    - [配置http服务](#配置http服务)
    - [下载Ambari](#下载ambari)
        - [centos7/readhat7 tar包](#centos7readhat7-tar包)
        - [repo](#repo)
    - [配置Ambari](#配置ambari)
    - [安装ambari](#安装ambari)
    - [正式安装](#正式安装)
        - [命令行安装Ambari-server](#命令行安装ambari-server)
        - [初始化](#初始化)
        - [数据库创建 ambari 库](#数据库创建-ambari-库)
        - [启动服务器](#启动服务器)
        - [访问界面配置](#访问界面配置)
        - [配置安装完后删除SmartSense](#配置安装完后删除smartsense)
- [遇到的问题](#遇到的问题)
    - [ssl问题](#ssl问题)
    - [安装HDP时，HST Agent Instal安装失败(扩展，任何一个组件都这样操作)](#安装hdp时hst-agent-instal安装失败扩展任何一个组件都这样操作)
    - [服务器软连接错误](#服务器软连接错误)
    - [KAFKA 外网连接配置](#kafka-外网连接配置)
    - [删除所有老包](#删除所有老包)

<!-- /TOC -->
# 安装前准备
## 1. 安装JDK1.8
------

### 卸载openjdk
1. 查看是否有openjdk
    ```sh
    rpm -qa | grep java
    ```
2. 通过命令删除
    ```sh
    yum remove "*openjdk*"
    ```
    >最好把前面列出来的，一个一个删除
    综合shell
    ```sh
    for i in $(rpm -qa | grep java);do yum remove -y $i;done
    ```
### 下载
[jdk8下载页面](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

#### tar包安装方式(.tar.gz)
将tar包解压到一个目录下，各人比较喜欢解压到 `/opt/run` 目录下，然后再通过软连接到 `/usr/local/java` 这样便于版本更新，再在 `/etc/profile`添加环境变量。 命令如下：
```sh
mkdir /opt/run
tar zxf jdk-8u181-linux-x64.tar.gz -C /opt/run
ln -s /opt/run/jdk1.8.0_181 /usr/local/java
cat << EOF >> /etc/profile
#JAVA_HOME
export JAVA_HOME=/usr/local/java
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib
export PATH=${PATH}:${JAVA_HOME}/bin
EOF
```

### rpm包安装方式(.rpm)
直接下载rpm包然后用 `rpm` 命令安装
```sh
rpm -ivh jdk-7u25-linux-x64.rpm
```



## 2. 系统要求
-------------------
### 2.1 系统软件要求
- yum and rpm (RHEL/CentOS/Oracle/Amazon Linux)
- `scp, curl, unzip, tar, wget,` and `gcc*`
- Python (with python-devel*)
>*Ambari Metrics Monitor uses a python library (psutil) which requires gcc and python-devel packages.
```sh
yum install -y scp curl unzip tar wget gcc python ntp
```
### 2.2 内存要求
|主机数|内存要求|磁盘要求|
|:-------:|:--------:|:--------:|
1       |1024 MB    |10 GB
10      |1024 MB    |20 GB
50      |2048 MB    |50 GB
100     |4096 MB    |100 GB
300     |4096 MB    |100 GB
500     |8096 MB    |200 GB
1000    |12288 MB   |200 GB
2000    |16384 MB   |500 GB


### 2.3 包大小和节点数
|      Name      |          Size   |Inodes|
|:---:|:---:|:---:|
Ambari Server               |100MB  |5,000
Ambari Agent                |8MB    |1,000
Ambari Metrics Collector    |225MB  |4,000
Ambari Metrics Monitor      |1MB    |100
Ambari Metrics Hadoop Sink  |8MB    |100
After Ambari Server Setup   |N/A    |4,000
After Ambari Server Start   |N/A    |500
After Ambari Agent Start    |N/A    |200

### 2.4 最大打开文件数
#### 查看命令
```sh
ulimit -Sn
ulimit -Hn
```
#### 配置教程
1. 修改 /etc/security/limits.conf 添加如下内容
```properties
* soft nofile 65536
* hard nofile 65536
* soft nproc unlimited
* hard nproc unlimited
```
修改语句：
```sh
cat << EOF >> /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft nproc unlimited
* hard nproc unlimited
EOF
```
2. 修改 /etc/security/limits.d/20-nproc.conf (centos6 /etc/security/limits.d/90-nproc.conf) 文件内容如下
```properties
*          soft    nproc     unlimited
root       soft    nproc     unlimited
```

## 3. 信息收集
-------
1. 收集主机名 `hostname -f`
2. 列出你想要在每个主机上安装的组件
3. 组建好各个数据目录


## 4. 安装之前准备工作
--------

### 4.1 免密登陆配置
1. 到 `~/.ssh/` 目录下先用 `ssh-keygen` 命令创建密钥公钥
2. 用 `ssh-copy-id` 进行配置
    ```shell
    ssh-copy-id hadoop@IP1
    ssh-copy-id hadoop@IP2
    ssh-copy-id hadoop@IP3
    ```
3. 测试是否通过

### 4.2用户权限控制
好像是创建各个用户，官网太多了，太难了

### 4.3NTP配置(有点问题，之后再看)
1. 安装 `yum install ntpdate ntp -y`
2. 配置 `vim /etc/ntp.conf`
    ```properties
    # For more information about this file, see the man pages
    # ntp.conf(5), ntp_acc(5), ntp_auth(5), ntp_clock(5), ntp_misc(5), ntp_mon(5).
    
    driftfile /var/lib/ntp/drift
    logfile /var/log/ntpd.log
    
    # Permit time synchronization with our time source, but do not
    # permit the source to query or modify the service on this system.
    restrict default nomodify notrap nopeer noquery
    
    # Permit all access over the loopback interface.  This could
    # be tightened as well, but to do so would effect some of
    # the administrative functions.
    restrict 127.0.0.1
    restrict ::1
    restrict 192.168.198.0 mask 255.255.255.0 nomodify notrap
    
    # Hosts on local network are less restricted.
    #restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap
    
    # Use public servers from the pool.ntp.org project.
    # Please consider joining the pool (http://www.pool.ntp.org/join.html).
    #server 0.centos.pool.ntp.org iburst
    #server 1.centos.pool.ntp.org iburst
    #server 2.centos.pool.ntp.org iburst
    #server 3.centos.pool.ntp.org iburst
    
    server 0.cn.pool.ntp.org iburst
    server 1.cn.pool.ntp.org iburst
    server 2.cn.pool.ntp.org iburst
    server 3.cn.pool.ntp.org iburst
    
    #新增:当外部时间不可用时，使用本地时间.
    server 192.168.198.53 iburst
    fudge 127.0.0.1 stratum 10
    
    #broadcast 192.168.1.255 autokey	# broadcast server
    #broadcastclient			# broadcast client
    #broadcast 224.0.1.1 autokey		# multicast server
    #multicastclient 224.0.1.1		# multicast client
    #manycastserver 239.255.254.254		# manycast server
    #manycastclient 239.255.254.254 autokey # manycast client
    restrict 0.cn.pool.ntp.org nomodify notrap noquery
    restrict 1.cn.pool.ntp.org nomodify notrap noquery
    restrict 2.cn.pool.ntp.org nomodify notrap noquery
    
    # Enable public key cryptography.
    #crypto
    
    includefile /etc/ntp/crypto/pw
    
    # Key file containing the keys and key identifiers used when operating
    # with symmetric key cryptography.
    keys /etc/ntp/keys
    
    # Specify the key identifiers which are trusted.
    #trustedkey 4 8 42
    
    # Specify the key identifier to use with the ntpdc utility.
    #requestkey 8
    
    # Specify the key identifier to use with the ntpq utility.
    #controlkey 8
    
    # Enable writing of statistics records.
    #statistics clockstats cryptostats loopstats peerstats
    
    # Disable the monitoring facility to prevent amplification attacks using ntpdc
    # monlist command when default restrict does not include the noquery flag. See
    # CVE-2013-5211 for more details.
    # Note: Monitoring will not be disabled with the limited restriction flag.
    disable monitor
    ```


### 4.4 DNS 和 NSCD配置
#### hosts file
将三台主机和ip添加进`/etc/hosts`文件就可以了
#### hostname
需要配置成正式域名的样式
```sh
hostnamectl set-hostname xxx --static
```
#### 网络配置
给 `/etc/sysconfig/network` 文件缇娜家内容
```sh
NETWORKING=yes
HOSTNAME=<fully.qualified.domain.name>
```
快捷命令
```sh
cat << EOF >> /etc/sysconfig/network
# Created by anaconda
NETWORKING=yes
HOSTNAME=data1
EOF
```


### 4.5 防火墙配置
```sh
systemctl disable firewalld
service firewalld stop
```
### 4.6 selinux配置
1. 一次性修改 `setenforce 0`
2. 永久修改：编辑`/etc/selinux/config`文件,
    ```properties
    SELINUX=disabled
    ```
    ```sh
    sed 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config -i`
    ```
3. 修改`/etc/yum/pluginconf.d/refresh-packagekit.conf`
    ```properties
    enabled=0
    ```
3. umask 配置，ambari和HDP只支持022或者027，如果默认是022或者0022就不用修改，永久修改方法 
    ```sh
    echo "umask 0022" >> /etc/profile
    ```
### 4.7 数据库配置
#### MySQL配置
1. 配置最高权限
    ```sql
    CREATE USER 'rangerdba'@'localhost' IDENTIFIED BY 'rangerdba';
    GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost';
    CREATE USER 'rangerdba'@'%' IDENTIFIED BY 'rangerdba';
    GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%';
    GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'localhost' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON *.* TO 'rangerdba'@'%' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
    ```
2. 配置 SAM
    ```sql
    create database registry;
    create database streamline;
    CREATE USER 'registry'@'%' IDENTIFIED BY '123456';
    CREATE USER 'streamline'@'%' IDENTIFIED BY '123456';
    GRANT ALL PRIVILEGES ON registry.* TO 'registry'@'%' WITH GRANT OPTION ;
    GRANT ALL PRIVILEGES ON streamline.* TO 'streamline'@'%' WITH GRANT OPTION ;
    commit;
    ```
3. 配置 Druid
    ```sql
    CREATE DATABASE druid DEFAULT CHARACTER SET utf8;
    CREATE DATABASE superset DEFAULT CHARACTER SET utf8;
    CREATE USER 'druid'@'%' IDENTIFIED BY '123456';
    CREATE USER 'superset'@'%' IDENTIFIED BY '123456';
    GRANT ALL PRIVILEGES ON *.* TO 'druid'@'%' WITH GRANT OPTION;
    GRANT ALL PRIVILEGES ON *.* TO 'superset'@'%' WITH GRANT OPTION;
    commit;
    ```
4. 配置管理员用户
    ```sql
    create database ambari character set utf8 ;  
    CREATE USER 'ambari'@'%'IDENTIFIED BY '123456';
    GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'%';
    FLUSH PRIVILEGES;
    ```
5. 统一执行
    ```sql
    create database ambari character set utf8;
    CREATE USER 'ambari'@'%' IDENTIFIED BY '123456';
    GRANT ALL PRIVILEGES ON *.* TO 'ambari'@'%';
    FLUSH PRIVILEGES;
    create database hive character set utf8;
    CREATE USER 'hive'@'%' IDENTIFIED BY '123456';
    GRANT ALL PRIVILEGES ON hive.* TO 'hive'@'%';
    FLUSH PRIVILEGES;
    create database oozie character set utf8;
    CREATE USER 'oozie'@'%' IDENTIFIED BY '123456';
    GRANT ALL PRIVILEGES ON oozie.* TO 'oozie'@'%';
    FLUSH PRIVILEGES;
    create database ranger character set utf8;
    CREATE USER 'rangeradmin'@'%' IDENTIFIED BY '123456';
    GRANT ALL PRIVILEGES ON rangeradmin.* TO 'rangeradmin'@'%';
    FLUSH PRIVILEGES;
    ```
4. 安装连接器

用任意方式将mysql连接jar包放到服务器上，然后启动之前用下列命令制定一下就好了
```s
ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
```

#### PostgreSQL配置(略)
#### Oracle 配置(略)

### 4.8 数据库安装
#### MySQL
1. 安装服务
    ```sh
    yum localinstall https://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
    yum install mysql-community-server
    systemctl start mysqld.service
    ```
2. 获取 root 初始密码
    ```sh
    grep 'A temporary password is generated for root@localhost' /var/log/mysqld.log |tail -1
    ```
3. 修改root密码
    ```sql
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';
    ```
#### PostgreSQL(略)
#### Oracle(略)

# 本地源安装
## 配置http服务
1. 安装 yum 工具 `yum install yum-utils createrepo`
2. 安装 httpd `yum install -y httpd`

## 下载Ambari
### centos7/readhat7 tar包
[Ambari 2.7.3](http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.3.0/ambari-2.7.3.0-centos7.tar.gz)
[Ambari 2.7.4](http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.4.0/ambari-2.7.4.0-centos7.tar.gz)

[HDP 3.1.0](http://public-repo-1.hortonworks.com/HDP/centos7/3.x/updates/3.1.0.0/HDP-3.1.0.0-centos7-rpm.tar.gz)
[HDP-UTILS 3.1.0](http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.22/repos/centos7/HDP-UTILS-1.1.0.22-centos7.tar.gz)
[HDP-GPL 3.1.0](http://public-repo-1.hortonworks.com/HDP-GPL/centos7/3.x/updates/3.1.0.0/HDP-GPL-3.1.0.0-centos7-gpl.tar.gz)

[HDP-3.1.4](http://public-repo-1.hortonworks.com/HDP/centos7/3.x/updates/3.1.4.0/HDP-3.1.4.0-centos7-rpm.tar.gz)
[HDP-UTILS-1.1.0.22](http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.22/repos/centos7/HDP-UTILS-1.1.0.22-centos7.tar.gz)
[HDP-GPL-3.1.4](http://public-repo-1.hortonworks.com/HDP-GPL/centos7/3.x/updates/3.1.4.0/HDP-GPL-3.1.4.0-centos7-gpl.tar.gz)



### repo
[Ambari 2.7.4](http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.4.0/ambari.repo)
[hdp.gpl 3.1.4](http://public-repo-1.hortonworks.com/HDP-GPL/centos7/3.x/updates/3.1.4.0/hdp.gpl.repo)
[HDP 3.14](http://public-repo-1.hortonworks.com/HDP/centos7/3.x/updates/3.1.4.0/hdp.repo)


## 配置Ambari
1. 安装httpd服务
    ```
    yum install -y httpd
    ```
2. 会有目录 `/var/www/html` 并创建目录 
   ```
   mkdir -p /var/www/html/ambari/2.7.4
   mkdir -p /var/www/html/hdp/3.1.4
   ```
3. 将之前下的包都解压到ambari目录下
    ```
    tar zxf ambari-2.7.4.0-centos7.tar.gz -C /var/www/html/ambari/2.7.4
    tar zxf HDP-3.1.4.0-centos7-rpm.tar.gz -C /var/www/html/hdp/3.1.4
    tar zxf HDP-UTILS-1.1.0.22-centos7.tar.gz -C /var/www/html/hdp/3.1.4
    tar zxf HDP-GPL-3.1.4.0-centos7-gpl.tar.gz -C /var/www/html/hdp/3.1.4
    ```
>访问网址没问题即可

1. 获取repo配置文件 
    ```
    wget http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.4.0/ambari.repo -P /etc/yum.repos.d
    wget http://public-repo-1.hortonworks.com/HDP-GPL/centos7/3.x/updates/3.1.4.0/hdp.gpl.repo -P /etc/yum.repos.d
    wget http://public-repo-1.hortonworks.com/HDP/centos7/3.x/updates/3.1.4.0/hdp.repo -P /etc/yum.repos.d
    ```
2. 配置repo文件
    
    ambari.repo
    ```properties
    #VERSION_NUMBER=2.7.4.0-118
    [ambari-2.7.4.0]
    name=ambari Version - ambari-2.7.4.0
    baseurl=http://data1/ambari/2.7.4/ambari/centos7/2.7.4.0-118/
    gpgcheck=1
    gpgkey=http://data1/ambari/2.7.4/ambari/centos7/2.7.4.0-118/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    ```
    
    hdp.repo
    ```properties
    #VERSION_NUMBER=3.1.4.0-315
    [HDP-3.1.4.0]
    name=HDP Version - HDP-3.1.4.0
    baseurl=http://data1/hdp/3.1.4/HDP/centos7/3.1.4.0-315/
    gpgcheck=1
    gpgkey=http://data1/hdp/3.1.4/HDP/centos7/3.1.4.0-315/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    
    
    [HDP-UTILS-1.1.0.22]
    name=HDP-UTILS Version - HDP-UTILS-1.1.0.22
    baseurl=http://data1/hdp/3.1.4/HDP-UTILS/centos7/1.1.0.22/
    gpgcheck=1
    gpgkey=http://data1/hdp/3.1.4/HDP-UTILS/centos7/1.1.0.22/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    ```
    hdp.gpl.repo
    ```properties
    #VERSION_NUMBER=3.1.4.0-315
    [HDP-GPL-3.1.4.0]
    name=HDP-GPL Version - HDP-GPL-3.1.4.0
    baseurl=http://data1/hdp/3.1.4/HDP-GPL/centos7/3.1.4.0-315/
    gpgcheck=1
    gpgkey=http://data1/hdp/3.1.4/HDP-GPL/centos7/3.1.4.0-315/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    ```
3. 生成本地源
    ```centos
    createrepo /var/www/html/hdp/3.1.4/HDP/centos7/
    createrepo /var/www/html/hdp/3.1.4/HDP-UTILS/
    ```
4. 将 `ambari.repo hdp.repo hdp.gpl.repo` 三个文件复制到其他机器上
    ```sh
    for i in {/etc/yum.repos.d/ambari.repo,/etc/yum.repos.d/hdp.repo,/etc/yum.repos.d/hdp.gpl.repo};do for h in {data2,data3};do scp $i root@$h:/etc/yum.repos.d;done;done
    ```
5. 关闭 `gpgcheck`
   ```sh
    echo "gpgcheck=0" >> /etc/yum/pluginconf.d/priorities.conf
   ```
## 安装ambari
1. 删除一些目录
```
rm -rf /etc/hadoop
rm -rf /etc/hbase
rm -rf /etc/oozie
rm -rf /etc/zookeeper
rm -rf /etc/tez
rm -rf /etc/kafka
rm -rf /etc/spark
rm -rf /etc/ambari-metrics-monitor
rm -rf /var/run/hadoop
rm -rf /var/run/hbase
rm -rf /var/run/zookeeper
rm -rf /var/run/hadoop-yarn
rm -rf /var/run/hadoop-mapreduce
rm -rf /var/run/kafka
rm -rf /var/run/spark
rm -rf /var/run/ambari-metrics-monitor
rm -rf /var/log/hadoop
rm -rf /var/log/hbase
rm -rf /var/log/zookeeper
rm -rf /var/log/hadoop-hdfs
rm -rf /var/log/hadoop-yarn
rm -rf /var/log/hadoop-mapreduce
rm -rf /var/log/kafka
rm -rf /var/log/spark
rm -rf /var/log/ambari-metrics-monitor
rm -rf /usr/lib/flume
rm -rf /usr/lib/storm
rm -rf /var/lib/zookeeper
rm -rf /var/lib/hadoop-hdfs
rm -rf /var/lib/hadoop-yarn
rm -rf /var/lib/hadoop-mapreduce
rm -rf /hadoop/zookeeper
rm -rf /hadoop/hdfs
rm -rf /hadoop/yarn
rm -rf /kafka-logs
rm -rf /etc/hive
rm -rf /etc/hive-hcatalog
rm -rf /etc/hive-webhcat
rm -rf /etc/slider
rm -rf /etc/storm-slider-client
rm -rf /etc/pig
rm -rf /var/run/hive
rm -rf /var/log/hive
rm -rf /var/log/hive-hcatalog
rm -rf /var/lib/hive
rm -rf /var/lib/slider
rm -rf /etc/ambari-metrics-collector
rm -rf /var/run/webhcat
rm -rf /var/run/ambari-metrics-collector
rm -rf /var/log/ambari-metrics-collector
rm -rf /usr/lib/ambari-metrics-collector
rm -rf /var/lib/ambari-metrics-collector
rm -rf /tmp/hadoop-hdfs
rm -rf /var/log/webhcat
rm -rf /tmp/hive
rm -rf /tmp/hcat
```
2. 删除用户
```sh
userdel hadoop
userdel hive
userdel zookeeper
userdel oozie
userdel ams
userdel tez
userdel zeppelin
userdel spark
userdel ambari-qa
userdel kafka
userdel hdfs
userdel sqoop
userdel yarn
userdel mapred
userdel hbase
userdel hcat
userdel zookeeper
userdel ams
userdel hdfs
```
## 正式安装
### 命令行安装Ambari-server
```shell
yum install ambari-server
```
### 初始化
```sh
ambari-server setup  --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar
ambari-server setup
```
- [ ] 添加 `setup` 安装步骤图
### setup选择
如图：



### 数据库创建 ambari 库
```
mysql -uambari -p ambari < /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql
```
### 启动服务器
```
ambari-server start
```
### 访问界面配置
1. 浏览器输入 `http://data1:8080`
2. 输入用户名密码登录 默认为 `admin admin`
3. GetStart 填入集群名字 `ewell`
![集群名称设置](https://s2.ax1x.com/2020/02/28/3D2oPH.png)
4. Select Version 选择 3.1.4 版本,删除其他源只留下 `redhat7`,配置如下
   ```
    HDP-3.1             http://data1/hdp/3.1.4/HDP/centos7/3.1.4.0-315/
    HDP-3.1-GPL         http://data1/hdp/3.1.4/HDP-GPL/centos7/3.1.4.0-315/
    HDP-UTILS-1.1.0.22  http://data1/hdp/3.1.4/HDP-UTILS/centos7/1.1.0.22/
   ```
![HDP源配置](https://s2.ax1x.com/2020/02/28/3DWOUS.png)
5. Target Hosts 配置 `data[1-3]`
6. Host Registration Information 配置 `Ambari-server` 的私钥
7. Confirm Hosts 之前手动安装过 `Ambari-agent` 就很快
8. 选择配置这些要根据实际需求了
9. 安装各种组件
10. 初始界面
11. 删除 `SmartSense`
基本就按步骤配，遇到问题看下面
- [ ] 添加界面操作截图


### 配置安装完后删除SmartSense
由于这个服务是辅助hadoop的并且，没有id就启动不了，而id是官网发放的，所以就干脆删除了
```sh
curl -u admin:admin -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Stop SmartSense via REST"}, "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' http://data1:8080/api/v1/clusters/ewell/services/SMARTSENSE

curl -u admin:admin -i -H 'X-Requested-By: ambari' -X POST -d '{"RequestInfo": {"context" :"Uninstall SmartSense via REST", "command":"Uninstall"}, "Requests/resource_filters":[{"hosts":"comma separated host names", "service_name":"SMARTSENSE", "component_name":"HST_AGENT"}]}' http://data1:8080/api/v1/clusters/ewell/requests

curl -u admin:admin -H 'X-Requested-By: ambari' -X DELETE http://data1:8080/api/v1/clusters/ewell/services/SMARTSENSE
```


#  遇到的问题
## ssl问题
```
etUtil.py:96 - EOF occurred in violation of protocol (_ssl.c:579)
NetUtil.py:97 - SSLError: Failed to connect. Please check openssl library versions.
```
编辑 `/etc/ambari-agent/conf/ambari-agent.ini` 文件，添加
```INI
[security]
force_https_protocol=PROTOCOL_TLSv1_2
```
## 安装HDP时，HST Agent Instal安装失败(扩展，任何一个组件都这样操作)
哪台主机错误，就把对应的软件删除了，然后在页面重装
1. yum list | grep xxxx
2. yum remove hadoop*
3. repeat

## 服务器软连接错误
zookeeper无法安装，服务器文件是在老的软链接


## KAFKA 外网连接配置
1. 在kafka配置界面，`Manage Config Groups` 新增3个组，并且每个分组添加对应服务器
![管理配置组](https://s2.ax1x.com/2019/11/18/Myn81J.png)
![管理界面](https://s2.ax1x.com/2019/11/18/MynI3Q.png)
![新增三个分组](https://s2.ax1x.com/2019/11/18/Mynocj.png)
![右边框框点加号](https://s2.ax1x.com/2019/11/18/MynbBq.png)
![选择对应的服务器](https://s2.ax1x.com/2019/11/18/Mynj4U.png)
![添加完成后的管理界面](https://s2.ax1x.com/2019/11/18/MyukE6.png)
2. 配置服务器ip配置，每个组的每个 `listeners` 对应着各自的ip
![点击保存后的界面，点击Listeners右边绿色加号](https://s2.ax1x.com/2019/11/18/MyuZCD.png)
![选择服务器](https://s2.ax1x.com/2019/11/18/Myu3Uf.png)
![配置对应的IP地址](https://s2.ax1x.com/2019/11/18/MyuY8g.png)
![配置完成截图](https://s2.ax1x.com/2019/11/18/MyuaKs.png)
3. 配置结束后，重启
![重启kafka服务](https://s2.ax1x.com/2019/11/18/Myuwbq.png)
![重启服务后](https://s2.ax1x.com/2019/11/18/MyuyPU.png)

## 删除所有老包
```sh
yum remove $(yum list installed | grep HDP | awk '{print $1}') -y
```