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
    GRANT ALL PRIVILEGES ON ambari.* TO 'ambari'@'%';
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

[HDP 3.1.0](http://public-repo-1.hortonworks.com/HDP/centos7/3.x/updates/3.1.0.0/HDP-3.1.0.0-centos7-rpm.tar.gz)

[HDP-UTILS 3.1.0](http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.22/repos/centos7/HDP-UTILS-1.1.0.22-centos7.tar.gz)

[HDP-GPL 3.1.0](http://public-repo-1.hortonworks.com/HDP-GPL/centos7/3.x/updates/3.1.0.0/HDP-GPL-3.1.0.0-centos7-gpl.tar.gz)

### repo



## 配置Ambari
1. 安装httpd服务
    ```
    yum install -y httpd
    ```
2. 会有目录 `/var/www/html` 创建目录 `/var/www/html/ambari`
3. 将之前下的包都解压到ambari目录下
    ```
    tar zxf ambari-2.7.3.0-centos7.tar.gz -C /var/www/html/ambari
    tar zxf HDP-3.1.0.0-centos7-rpm.tar.gz -C /var/www/html/ambari
    tar zxf HDP-UTILS-1.1.0.22-centos7.tar.gz -C /var/www/html/ambari
    tar zxf HDP-GPL-3.1.0.0-centos7-gpl.tar.gz -C /var/www/html/ambari
    ```
>访问网址没问题即可

4. 获取repo配置文件 
    ```
    wget http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.7.3.0/ambari.repo -p /etc/yum.repos.d
    wget http://public-repo-1.hortonworks.com/HDP/centos7/3.x/updates/3.1.0.0/hdp.repo -p /etc/yum.repos.d
    wget http://public-repo-1.hortonworks.com/HDP-GPL/centos7/3.x/updates/3.1.0.0/hdp.gpl.repo -p /etc/yum.repos.d
    ```
5. 配置repo文件
    
    ambari.repo
    ```properties
    #VERSION_NUMBER=2.7.3.0-139
    [ambari-2.7.3.0]
    name=ambari Version - ambari-2.7.3.0
    baseurl=http://data1/ambari/centos7/2.7.3.0-139/
    gpgcheck=1
    gpgkey=http://s3.amazonaws.com/dev.hortonworks.com/ambari/centos7/2.x/BUILDS/2.7.3.0-139/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    ```
    
    hdp.repo
    ```properties
    #VERSION_NUMBER=3.1.0.0-78
    [HDP-3.1.0.0]
    name=HDP Version - HDP-3.1.0.0
    baseurl=http://data1/hdp/HDP/centos7/3.1.0.0-78/
    gpgcheck=1
    gpgkey=http://data1/hdp/HDP/centos7/3.1.0.0-78/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1


    [HDP-UTILS-1.1.0.22]
    name=HDP-UTILS Version - HDP-UTILS-1.1.0.22
    baseurl=http://data1/hdp/HDP-UTILS/centos7/1.1.0.22/
    gpgcheck=1
    gpgkey=http://data1/hdp/HDP-UTILS/centos7/1.1.0.22/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    ```
    hdp.gpl.repo
    ```properties
    #VERSION_NUMBER=3.1.0.0-78
    [HDP-GPL-3.1.0.0]
    name=HDP-GPL Version - HDP-GPL-3.1.0.0
    baseurl=http://data1/hdp/HDP-GPL/centos7/3.1.0.0-78/
    gpgcheck=1
    gpgkey=http://data1/hdp/HDP-GPL/centos7/3.1.0.0-78/RPM-GPG-KEY/RPM-GPG-KEY-Jenkins
    enabled=1
    priority=1
    ```
6. 生成本地源
    ```centos
    createrepo /var/www/html/hdp/HDP/centos7/
    createrepo /var/www/html/hdp/HDP-UTILS/
    ```

## 安装ambari
```

```

#  遇到的问题