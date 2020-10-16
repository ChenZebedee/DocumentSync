<!-- TOC -->

- [系统准备](#系统准备)
    - [磁盘准备](#磁盘准备)
    - [包准备](#包准备)
    - [挂载cdrom](#挂载cdrom)
    - [/etc/hosts 配置](#etchosts-配置)
    - [信息收集](#信息收集)
    - [系统参数设置&工具使用](#系统参数设置工具使用)
        - [selinux配置](#selinux配置)
        - [免密登陆配置](#免密登陆配置)
        - [DNS 和 NSCD配置](#dns-和-nscd配置)
            - [hosts file](#hosts-file)
            - [hostname](#hostname)
            - [网络配置](#网络配置)
        - [防火墙配置](#防火墙配置)
        - [NTP配置](#ntp配置)
            - [1. 安装 `yum install ntpdate ntp -y`](#1-安装-yum-install-ntpdate-ntp--y)
            - [2. /etc/ntp.conf配置](#2-etcntpconf配置)
        - [每台机器重启ntp服务器](#每台机器重启ntp服务器)
    - [离线yum包安装](#离线yum包安装)
    - [JAVA安装](#java安装)
    - [安装MySQL](#安装mysql)
    - [配置Ambari](#配置ambari)
        - [复制MySQL驱动程序](#复制mysql驱动程序)
    - [安装ambari](#安装ambari)
        - [启动httpd](#启动httpd)
        - [命令行安装Ambari-server](#命令行安装ambari-server)
        - [初始化](#初始化)
        - [setup选择](#setup选择)
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
    - [宕机重启后 Ambari Metrics 启动失败](#宕机重启后-ambari-metrics-启动失败)

<!-- /TOC -->

# 系统准备

## 磁盘准备

将数据盘挂载到 `/data` 下

```
mount /xxx/xxx/xxx /data
```

## 包准备

1. ambari-2.7.4.0-centos7.tar.gz
2. ambari.repo
3. cache.tar.gz
4. Centos-7.repo
5. HDP-3.1.4.0-centos7-rpm.tar.gz
6. HDP-GPL-3.1.4.0-centos7-gpl.tar.gz
7. HDP-UTILS-1.1.0.22-centos7.tar.gz
8. hdp.gpl.repo
9. hdp.repo
10. jdk-8u181-linux-x64.tar.gz
11. libxml2-2.9.1-6.el7_2.3.x86_64.rpm
12. mysql-5.7.29-1.el7.x86_64.rpm-bundle.tar
13. rpm-gpg.tar.gz
14. scala-2.11.12.tgz
15. scala-2.12.10.tgz

## 挂载cdrom

```sh
mkdir -p /cdbase
mount /dev/cdrom /cdbase/
mkdir /etc/yum.repos.d/bak
mv /etc/yum.repos.d/* /etc/yum.repos.d/bak/
cat << EOF > /etc/yum.repos.d/CentOS-Media.repo
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
```

## /etc/hosts 配置

1. 第一台配置`/etc/hosts`

2. 通过`ssh-keygen`

## 信息收集

1. 收集主机名 `hostname -f`

2. 列出你想要在每个主机上安装的组件

3. 组建好各个数据目录

## 系统参数设置&工具使用

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

    修改语句

    ```sh
    sed 's#4096#unlimited#g' /etc/security/limits.d/20-nproc.conf -i
    ```

### selinux配置

1. 一次性修改 `setenforce 0`

2. 永久修改：编辑`/etc/selinux/config`文件,

    ```properties
    SELINUX=disabled
    ```

    ```sh
    sed 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config -i
    ```

3. 修改`/etc/yum/pluginconf.d/refresh-packagekit.conf`

    ```properties
    enabled=0
    ```

    语句：

    ```sh
    echo 'enabled=0' > /etc/yum/pluginconf.d/refresh-packagekit.conf 
    ```

4. umask 配置，ambari和HDP只支持022或者027，如果默认是022或者0022就不用修改，永久修改方法

    ```sh
    echo "umask 0022" >> /etc/profile
    ```

### 免密登陆配置

1. 到 `~/.ssh/` 目录下先用 `ssh-keygen` 命令创建密钥公钥

2. 用 `ssh-copy-id` 进行配置

    ```shell
    ssh-copy-id hadoop@IP1
    ssh-copy-id hadoop@IP2
    ssh-copy-id hadoop@IP3
    ```

3. 测试是否通过

### DNS 和 NSCD配置

#### hosts file

将三台主机和ip添加进`/etc/hosts`文件就可以了

#### hostname

需要配置成正式域名的样式

```sh
hostnamectl set-hostname xxx --static
```

#### 网络配置

给 `/etc/sysconfig/network` 文件添加内容

```sh
NETWORKING=yes
HOSTNAME=<fully.qualified.domain.name>
```

样例命令

```sh
cat << EOF >> /etc/sysconfig/network
# Created by anaconda
NETWORKING=yes
HOSTNAME=data1
EOF
```

### 防火墙配置

```sh
systemctl disable firewalld
service firewalld stop
```

### NTP配置

#### 1. 安装 `yum install ntpdate ntp -y`

#### 2. /etc/ntp.conf配置

1. 服务端配置

    ```properties
    cat << EOF > /etc/ntp.conf
    # For more information about this file, see the man pages
    # ntp.conf(5), ntp_acc(5), ntp_auth(5), ntp_clock(5), ntp_misc(5), ntp_mon(5).

    driftfile /var/lib/ntp/drift

    # Permit time synchronization with our time source, but do not
    # permit the source to query or modify the service on this system.
    restrict default nomodify notrap nopeer noquery

    # Permit all access over the loopback interface.  This could
    # be tightened as well, but to do so would effect some of
    # the administrative functions.
    restrict 127.0.0.1
    restrict ::1
    restrict ${server_network} mask 255.255.255.0

    # Hosts on local network are less restricted.
    #restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap

    # Use public servers from the pool.ntp.org project.
    # Please consider joining the pool (http://www.pool.ntp.org/join.html)
    #server 0.cn.pool.ntp.org
    #server 1.cn.pool.ntp.org
    #server 2.cn.pool.ntp.org
    #server 3.cn.pool.ntp.org

    server 127.127.1.0     # local clock
    fudge  127.127.1.0 stratum 10

    #broadcast 192.168.1.255 autokey	# broadcast server
    #broadcastclient			# broadcast client
    #broadcast 224.0.1.1 autokey		# multicast server
    #multicastclient 224.0.1.1		# multicast client
    #manycastserver 239.255.254.254		# manycast server
    #manycastclient 239.255.254.254 autokey # manycast client

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

2. 配置客户端

    ```properties
    # For more information about this file, see the man pages
    # ntp.conf(5), ntp_acc(5), ntp_auth(5), ntp_clock(5), ntp_misc(5), ntp_mon(5).

    driftfile /var/lib/ntp/drift

    # Permit time synchronization with our time source, but do not
    # permit the source to query or modify the service on this system.
    restrict default nomodify notrap nopeer noquery

    # Permit all access over the loopback interface.  This could
    # be tightened as well, but to do so would effect some of
    # the administrative functions.
    restrict 127.0.0.1
    restrict ::1

    # Hosts on local network are less restricted.
    #restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap

    # Use public servers from the pool.ntp.org project.
    # Please consider joining the pool (http://www.pool.ntp.org/join.html).
    #server 0.centos.pool.ntp.org iburst
    #server 1.centos.pool.ntp.org iburst
    #server 2.centos.pool.ntp.org iburst
    #server 3.centos.pool.ntp.org iburst
    server ${server_ip}

    #broadcast 192.168.1.255 autokey	# broadcast server
    #broadcastclient			# broadcast client
    #broadcast 224.0.1.1 autokey		# multicast server
    #multicastclient 224.0.1.1		# multicast client
    #manycastserver 239.255.254.254		# manycast server
    #manycastclient 239.255.254.254 autokey # manycast client

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

### 每台机器重启ntp服务器

```sh
systemctl restart ntpd
```

## 离线yum包安装

## JAVA安装

1. 查看是否有自带 `open JDK`

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

3. 下载 `oracle JDK`

    [jdk8下载页面](https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

4. 复制到每台机器下

    ```sh
    for name in $(cat /etc/hosts | awk '{print $2}');do scp jdk-8u181-linux-x64.tar.gz  $name:;done
    ```

5. tar包安装方式(.tar.gz)

    将tar包解压到一个目录下，各人比较喜欢解压到 `/opt/run` 目录下，然后再通过软连接到 `/usr/local/java` 这样便于版本更新，再在 `/etc/profile`添加环境变量。 命令如下：

    ```sh
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
    rm -f jdk-8u181-linux-x64.tar.gz
    ```

## 安装MySQL

1. 先删除自带 mariadb-libs-5.5.60-1.el7_5.x86_64

    ```shell
    yum remove mariadb* -y
    rpm -e --nodeps mariadb-libs-5.5.60-1.el7_5.x86_64
    ```

2. 按顺序安装包

    ```sh
    rpm -ivh mysql-community-common-5.7.29-1.el7.x86_64.rpm
    rpm -ivh mysql-community-libs-5.7.29-1.el7.x86_64.rpm
    rpm -ivh mysql-community-client-5.7.29-1.el7.x86_64.rpm
    rpm -ivh mysql-community-server-5.7.29-1.el7.x86_64.rpm
    rpm -ivh mysql-community-devel-5.7.29-1.el7.x86_64.rpm
    ```

3. 设置简单密码模式

    ```sh
    echo "validate_password=off" >> /etc/my.cnf
    ```

4. 启动

    ```sh
    systemctl start mysqld
    ```

5. 查看初始化密码

    ```sh
    grep 'temporary password' /var/log/mysqld.log
    ```

6. 登陆之后修改密码修改密码

    ```sql
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'ewell@123';
    ```

7. 创建超级用户

    ```sql
    CREATE USER 'ewell'@'%' IDENTIFIED BY 'ewell@123';
    GRANT ALL ON *.* TO 'ewell'@'%';
    GRANT all ON *.* TO 'ewell'@'%' WITH GRANT OPTION;
    flush  privileges;
    ```

## 配置Ambari

1. 先配置数据库

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
    create database rangeradmin character set utf8;
    CREATE USER 'rangeradmin'@'%' IDENTIFIED BY '123456';
    GRANT ALL PRIVILEGES ON rangeradmin.* TO 'rangeradmin'@'%';
    GRANT ALL PRIVILEGES ON ranger.* TO 'rangeradmin'@'%';
    FLUSH PRIVILEGES;
    ```

2. 安装httpd服务

    ```sh
    yum install -y yum-utils createrepo httpd
    ```

3. 会有目录 `/var/www/html` 并创建目录

   ```sh
   mkdir -p /var/www/html/ambari/2.7.4
   mkdir -p /var/www/html/hdp/3.1.4
   ```

4. 将之前下的包都解压到ambari目录下

    ```sh
    tar zxf ambari-2.7.4.0-centos7.tar.gz -C /var/www/html/ambari/2.7.4
    tar zxf HDP-3.1.4.0-centos7-rpm.tar.gz -C /var/www/html/hdp/3.1.4
    tar zxf HDP-UTILS-1.1.0.22-centos7.tar.gz -C /var/www/html/hdp/3.1.4
    tar zxf HDP-GPL-3.1.4.0-centos7-gpl.tar.gz -C /var/www/html/hdp/3.1.4
    ```

5. 获取repo配置文件

    ```sh
    cp ambari.repo /etc/yum.repos.d
    cp hdp.gpl.repo /etc/yum.repos.d
    cp hdp.repo /etc/yum.repos.d
    ```

6. 配置repo文件

    ambari.repo:

    ```properties
    #VERSION_NUMBER=2.7.4.0-118
    [ambari-2.7.4.0]
    name=ambari Version - ambari-2.7.4.0
    baseurl=http://$(hostname)/ambari/2.7.4/ambari/centos7/2.7.4.0-118/
    gpgcheck=1
    gpgkey=http://$(hostname)/ambari/2.7.4/ambari/centos7/2.7.4.0-118/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    ```

    语句：

    ```sh
    cat << EOF > /etc/yum.repos.d/ambari.repo
    #VERSION_NUMBER=2.7.4.0-118
    [ambari-2.7.4.0]
    name=ambari Version - ambari-2.7.4.0
    baseurl=http://$(hostname)/ambari/2.7.4/ambari/centos7/2.7.4.0-118/
    gpgcheck=1
    gpgkey=http://$(hostname)/ambari/2.7.4/ambari/centos7/2.7.4.0-118/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    EOF
    ```

    hdp.repo

    ```properties
    #VERSION_NUMBER=3.1.4.0-315
    [HDP-3.1.4.0]
    name=HDP Version - HDP-3.1.4.0
    baseurl=http://$(hostname)/hdp/3.1.4/HDP/centos7/3.1.4.0-315/
    gpgcheck=1
    gpgkey=http://$(hostname)/hdp/3.1.4/HDP/centos7/3.1.4.0-315/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1

    [HDP-UTILS-1.1.0.22]
    name=HDP-UTILS Version - HDP-UTILS-1.1.0.22
    baseurl=http://$(hostname)/hdp/3.1.4/HDP-UTILS/centos7/1.1.0.22/
    gpgcheck=1
    gpgkey=http://$(hostname)/hdp/3.1.4/HDP-UTILS/centos7/1.1.0.22/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    ```

     语句：

    ```sh
    cat << EOF > /etc/yum.repos.d/hdp.repo
    #VERSION_NUMBER=3.1.4.0-315
    [HDP-3.1.4.0]
    name=HDP Version - HDP-3.1.4.0
    baseurl=http://$(hostname)/hdp/3.1.4/HDP/centos7/3.1.4.0-315/
    gpgcheck=1
    gpgkey=http://$(hostname)/hdp/3.1.4/HDP/centos7/3.1.4.0-315/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1

    [HDP-UTILS-1.1.0.22]
    name=HDP-UTILS Version - HDP-UTILS-1.1.0.22
    baseurl=http://$(hostname)/hdp/3.1.4/HDP-UTILS/centos7/1.1.0.22/
    gpgcheck=1
    gpgkey=http://$(hostname)/hdp/3.1.4/HDP-UTILS/centos7/1.1.0.22/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    EOF
    ```

    hdp.gpl.repo

    ```properties
    #VERSION_NUMBER=3.1.4.0-315
    [HDP-GPL-3.1.4.0]
    name=HDP-GPL Version - HDP-GPL-3.1.4.0
    baseurl=http://$(hostname)/hdp/3.1.4/HDP-GPL/centos7/3.1.4.0-315/
    gpgcheck=1
    gpgkey=http://$(hostname)/hdp/3.1.4/HDP-GPL/centos7/3.1.4.0-315/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    ```

    语句：

    ```sh
    cat << EOF > /etc/yum.repos.d/hdp.gpl.repo
    #VERSION_NUMBER=3.1.4.0-315
    [HDP-GPL-3.1.4.0]
    name=HDP-GPL Version - HDP-GPL-3.1.4.0
    baseurl=http://$(hostname)/hdp/3.1.4/HDP-GPL/centos7/3.1.4.0-315/
    gpgcheck=1
    gpgkey=http://$(hostname)/hdp/3.1.4/HDP-GPL/centos7/3.1.4.0-315/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    EOF
    ```

7. 将 `ambari.repo hdp.repo hdp.gpl.repo` 三个文件复制到其他机器上

    ```sh
    for i in {/etc/yum.repos.d/ambari.repo,/etc/yum.repos.d/hdp.repo,/etc/yum.repos.d/hdp.gpl.repo};do for h in $(cat /etc/hosts | awk '{print $2}');do scp $i root@$h:/etc/yum.repos.d;done;done
    ```

8. 生成本地源

    ```centos
    createrepo /var/www/html/hdp/3.1.4/HDP/centos7/
    createrepo /var/www/html/hdp/3.1.4/HDP-UTILS/
    ```

9. 关闭 `gpgcheck`

   ```sh
    echo "gpgcheck=0" >> /etc/yum/pluginconf.d/priorities.conf
   ```

### 复制MySQL驱动程序

>mv mysql-connector-java-5.1.47.jar /usr/share/java/mysql-connector-java.jar

## 安装ambari

### 启动httpd

```shell
systemctl start httpd
```

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

```sh
mysql -uambari -p ambari < /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql
```

### 启动服务器

```sh
ambari-server start
```

### 访问界面配置

1. 浏览器输入 `http://data1:8080`
2. 输入用户名密码登录 默认为 `admin admin`
3. GetStart 填入集群名字 `ewell`
![集群名称设置](https://s2.ax1x.com/2020/02/28/3D2oPH.png)
4. Select Version 选择 3.1.4 版本,删除其他源只留下 `redhat7`,配置如下

   ```p
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

### 配置安装完后删除SmartSense

由于这个服务是辅助hadoop的并且，没有id就启动不了，而id是官网发放的，所以就干脆删除了

```sh
curl -u admin:admin -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Stop SmartSense via REST"}, "Body": {"ServiceInfo": {"state": "INSTALLED"}}}' http://qysjzx1:8080/api/v1/clusters/qysjzx/services/SMARTSENSE

curl -u admin:admin -i -H 'X-Requested-By: ambari' -X POST -d '{"RequestInfo": {"context" :"Uninstall SmartSense via REST", "command":"Uninstall"}, "Requests/resource_filters":[{"hosts":"comma separated host names", "service_name":"SMARTSENSE", "component_name":"HST_AGENT"}]}' http://qysjzx1:8080/api/v1/clusters/qysjzx/requests

curl -u admin:admin -H 'X-Requested-By: ambari' -X DELETE http://qysjzx1:8080/api/v1/clusters/qysjzx/services/SMARTSENSE
```

# 遇到的问题

## ssl问题

```python
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

zookeeper无法安装，服务器文件是在老的软链接。在服务器上的/usr/hdp/current删除原来的zookeeper相关的目录重新安装即可

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

## 宕机重启后 Ambari Metrics 启动失败

到主机上，将相关进程强制 kill 之后，再次启动。