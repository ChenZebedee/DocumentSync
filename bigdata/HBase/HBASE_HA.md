# HBase 服务搭建

<!-- TOC -->

- [HBase 服务搭建](#hbase-服务搭建)
    - [服务器配置](#服务器配置)
    - [下载及文件目录](#下载及文件目录)
        - [下载](#下载)
        - [文件目录](#文件目录)
    - [配置文件修改](#配置文件修改)
        - [hbase-env.sh](#hbase-envsh)
        - [hbase-site.xml](#hbase-sitexml)
        - [log4j.properties](#log4jproperties)
        - [regionservers](#regionservers)
        - [backup-masters](#backup-masters)
    - [启动步骤](#启动步骤)

<!-- /TOC -->

## 服务器配置
1. 确保每台机器有固定 ip，不然下次重启 ip 重置就会导致服务启动失败
2. centos 6.5 系统
3. 新建 hadoop 用户，用于处理各个大数据组件
4. 配置 `/etc/host` 文件，所有集群都配置，dns解析名字与服务器名字要一致
5. 修改 ulimit 配置
```
1. 修改 /etc/security/limits.conf 添加如下内容
* soft nofile 65536
* hard nofile 65536
* soft nproc unlimited
* hard nproc unlimited

2. 修改 /etc/security/limits.d/90-nproc.conf 文件内容如下
*          soft    nproc     unlimited
root       soft    nproc     unlimited
```

6. 添加 /etc/profile 文件配置
```shell
cat << EOF >> /etc/profile
#HBASE
export HBASE_HOME=/opt/bigdata/hbase
export PATH=\$PATH:\$#HBASEHBASE_HOME/bin
EOF
```

## 下载及文件目录
### 下载
1. [zookeeper下载](http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz)
2. [hbase下载](http://mirror.bit.edu.cn/apache/hbase/2.1.6/hbase-2.1.6-bin.tar.gz)

### 文件目录
1. 目录选择新建用户的 home 目录，如果用户为 hadoop，则第一层目录为 `/home/hadoop`
2. 在用户目录先新建 `bigdata` 文件夹，用于存放大数据组件的运行目录
3. 在 `/opt` 目录下新建 `bigdata` 文件夹，用于软连接

## 配置文件修改
目录 `${HBASE_HOME}/conf`

### hbase-env.sh
1. 修改 `export JAVA_HOME`，配置成自己的 jdk 路径
2. 添加 `export HBASE_PID_DIR=` 配置成一个稳定目录，并且Hadoop有权限，不然放在 tmp 下定期会被删除
3. 添加 `export HBASE_CLASSPATH` 添加 Hadoop 的配置目录
4. 添加 `export HBASE_LOG_DIR` 配置日志存储位置
5. 添加 `export HBASE_MANAGES_ZK` 不启动自带 ZK，需要启动开源的 zookeeper

配置案例:
```shell
export JAVA_HOME=/usr/local/jdk1.8.0_181
export HBASE_PID_DIR=/opt/bigdata/hbase/tmp/pid
export HBASE_CLASSPATH=/opt/bigdata/hadoop/etc/hadoop
export HBASE_LOG_DIR=${HBASE_HOME}/logs
export HBASE_MANAGES_ZK=false
```

### hbase-site.xml

配置案例:
```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>hbase.rootdir</name> <!--配置HBase元数据存储目录-->
    <value>hdfs://ewell/hbase</value>
  </property>
<property>
  <name>hbase.zookeeper.quorum</name> <!--配置ZOOKEEPER 地址-->
  <value>hadoop01,hadoop02,hadoop03</value>
</property>
  <property>
    <name>hbase.zookeeper.property.dataDir</name> <!--配置 zk数据存放地址-->
    <value>/opt/bigdata/hbase/data</value>
  </property>
  <property>
    <name>hbase.unsafe.stream.capability.enforce</name> <!--是否开启流功能-->
    <value>false</value>
  </property>

<property>
<name>hbase.cluster.distributed</name> <!--是否保持集群运行-->
<value>true</value>
</property>

<property>
<name>hbase.master</name><!--Master 配置有多个就写端口就好，就一个要写主机名:端口-->
<value>60000</value>
</property>

<property>
<name>hbase.tmp.dir</name> <!--临时文件目录配置-->
<value>/opt/bigdata/hbase/tmp</value>
</property>


<property>
<name>hbase.zookeeper.property.clientPort</name><!--zookeeper端口配置-->
<value>2181</value>
</property>

<property>
<name>zookeeper.session.timeout</name><!--zookeeper 连接等待时间-->
<value>120000</value>
</property>

<property>
<name>hbase.regionserver.restart.on.zk.expire</name> <!--是否在regionserver 到期是重新注册-->
<value>true</value>
</property>

</configuration>
```

### log4j.properties
1. 修改`hbase.log.dir` 配置为自己的目录
### regionservers
1. 删除localhost
2. 添加要启动regionserver的主机名

### backup-masters
1. 在 conf 目录下创建文件 backup-masters 文件
2. 添加要作为备份主机的主机名

## 启动步骤
1. 启动外部[ZOOKEEPER]()
2. 在主Master 主机运行 start-hbase.sh命令