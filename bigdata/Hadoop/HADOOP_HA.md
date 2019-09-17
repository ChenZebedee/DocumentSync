# Hadoop HA 配置

<!-- TOC -->

- [Hadoop HA 配置](#hadoop-ha-配置)
    - [服务器基础配置](#服务器基础配置)
    - [下载及目录选择](#下载及目录选择)
        - [下载](#下载)
        - [目录选择](#目录选择)
    - [配置文件修改](#配置文件修改)
        - [core-site.xml 文件修改](#core-sitexml-文件修改)
        - [完成配置](#完成配置)
        - [hadoop-env.sh 文件修改](#hadoop-envsh-文件修改)
        - [hdfs-site.xml 文件修改](#hdfs-sitexml-文件修改)
        - [mapred-site.xml 文件修改](#mapred-sitexml-文件修改)
        - [yarn-site.xml 文件修改](#yarn-sitexml-文件修改)
        - [slaves 文件修改](#slaves-文件修改)
    - [启动步骤](#启动步骤)
    - [其他命令查看](#其他命令查看)
        - [查看 namenode 是否活动](#查看-namenode-是否活动)
        - [查看 resourcemanager 是否活动](#查看-resourcemanager-是否活动)

<!-- /TOC -->


## 服务器基础配置
1. 确保每台机器有固定 ip，不然下次重启 ip 重置就会导致服务启动失败
2. centos 6.5 系统
3. 新建 hadoop 用户，用于处理各个大数据组件
4. 配置 `/etc/host` 文件，所有集群都配置，dns解析名字与服务器名字要一致
5. 修改 `/etc/profile` 如下
```shell
cat << EOF >> /etc/profile
#HADOOP
export HADOOP_HOME=/opt/bigdata/hadoop
export PATH=\$PATH:\$HADOOP_HOME/bin
EOF
```

## 下载及目录选择
### 下载
1. [zookeeper下载](http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.14/zookeeper-3.4.14.tar.gz)
2. [hadoop下载](http://mirror.bit.edu.cn/apache/hadoop/common/hadoop-2.7.7/hadoop-2.7.7.tar.gz)
3. [hbase下载](http://mirror.bit.edu.cn/apache/hbase/2.1.6/hbase-2.1.6-bin.tar.gz)

### 目录选择
1. 目录选择新建用户的 home 目录，如果用户为 hadoop，则第一层目录为 `/home/hadoop`
2. 在用户目录先新建 `bigdata` 文件夹，用于存放大数据组件的运行目录
3. 在 `/opt` 目录下新建 `bigdata` 文件夹，用于软连接


## 配置文件修改
### core-site.xml 文件修改
1. `fs.defaultFS` -hdfs地址配置，格式为：`hdfs://${name}`
2. `dfs.journalnode.edits.dir` -journal文件存储地址(本地目录)
3. `ha.zookeeper.quorum` -ZK 服务器配置(带端口，用逗号分隔)
4. `dfs.ha.fencing.methods` -HA shell配置
5. `dfs.ha.fencing.ssh.private-key-files` -ssh 密钥地址
### 完成配置
```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
<property>
  <name>fs.defaultFS</name>
  <value>hdfs://ewell</value>
</property>
<property>
  <name>dfs.journalnode.edits.dir</name>
  <value>/opt/bigdata/hadoop/journal/local/data</value>
</property>
 <property>
   <name>ha.zookeeper.quorum</name>
   <value>hadoop01:2181,hadoop02:2181,hadoop03:2181</value>
 </property>
    <property>
      <name>dfs.ha.fencing.methods</name>
      <value>sshfence</value>
    </property>

    <property>
      <name>dfs.ha.fencing.ssh.private-key-files</name>
      <value>/home/hadoop/.ssh/id_rsa</value>
    </property>
</configuration>
```


### hadoop-env.sh 文件修改
1. `export JAVA_HOME=` 修改成自己的 JAVA 目录
2. `export HADOOP_PID_DIR=` 配置成一个指定目录，如 `/opt/bigdata/hadoop/pid` 避免长时间启动删除了默认存在/tmp的pid文件

### hdfs-site.xml 文件修改
>note: `dfs.nameservices` 与 core-site.xml 里的 `fs.defaultFS` 的名字配置要一致

```xml
<configuration>
<property>
  <name>dfs.nameservices</name>
  <value>ewell</value>
</property>
<property>
  <name>dfs.ha.namenodes.ewell</name>
  <value>nn1,nn2</value>
</property>
<property>
  <name>dfs.namenode.rpc-address.ewell.nn1</name>
  <value>hadoop01:8020</value>
</property>
<property>
  <name>dfs.namenode.rpc-address.ewell.nn2</name>
  <value>hadoop02:8020</value>
</property>
<property>
  <name>dfs.namenode.http-address.ewell.nn1</name>
  <value>hadoop01:50070</value>
</property>
<property>
  <name>dfs.namenode.http-address.ewell.nn2</name>
  <value>hadoop02:50070</value>
</property>
<property>
  <name>dfs.namenode.shared.edits.dir</name>
  <value>qjournal://hadoop01:8485;hadoop02:8485;hadoop03:8485/ewell</value>
</property>
<property>
  <name>dfs.client.failover.proxy.provider.ewell</name>
  <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
</property>
  <property>
    <name>dfs.journalnode.edits.dir</name>
    <value>/opt/bigdata/hadoop/dfs/journal</value>
  </property>
 <property>
   <name>dfs.ha.automatic-failover.enabled</name>
   <value>true</value>
 </property>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
    </property>
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>/opt/bigdata/hadoop/dfs/name</value>
  </property>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>/opt/bigdata/hadoop/dfs/data</value>
  </property>
</configuration>
```
### mapred-site.xml 文件修改
```xml
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
```
### yarn-site.xml 文件修改
```xml
<configuration>

<!-- Site specific YARN configuration properties -->
<!-- HA -->
<property>
  <name>yarn.resourcemanager.ha.enabled</name>
  <value>true</value>
</property>
<property>
  <name>yarn.resourcemanager.cluster-id</name>
  <value>ewell</value>
</property>
<property>
  <name>yarn.resourcemanager.ha.rm-ids</name>
  <value>rm1,rm2</value>
</property>
<property>
  <name>yarn.resourcemanager.hostname.rm1</name>
  <value>hadoop02</value>
</property>
<property>
  <name>yarn.resourcemanager.hostname.rm2</name>
  <value>hadoop03</value>
</property>
<property>
  <name>yarn.resourcemanager.webapp.address.rm1</name>
  <value>hadoop02:8088</value>
</property>
<property>
  <name>yarn.resourcemanager.webapp.address.rm2</name>
  <value>hadoop03:8088</value>
</property>
<property>
  <name>yarn.resourcemanager.zk-address</name>
  <value>hadoop01:2181,hadoop02:2181,hadoop03:2181</value>
</property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>


</configuration>
```

### slaves 文件修改
删除`localhost`添加数据节点服务器一行一个


## 启动步骤
1. `每台` 机器启动 Zookeeper 
    ```
    zkServer.sh start
    ```

2. 在 zookeeper 中注册
    ```
    hdfs zkfc -formatZK
    ```
3. `每台`机器启动 journal 服务
    ```s
    hadoop-daemon.sh start journalnode
    ```
4. namenode1 进行格式化
    ```
    hdfs namenode -format
    ```
5. 启动 namenode1 
    ```
    hadoop-daemon.sh start namenode
    ```
6. 在 nn2 进行元数据同步
    ```
    hdfs namenode -bootstrapStandby
    ```

7. 启动所有服务
    ```
    start-all.sh
    ```
8. 第三个节点没有自动启动 resourcemanager ，所以手动启动
    ```
    yarn-daemon.sh start resourcemanager
    ```


## 其他命令查看
### 查看 namenode 是否活动
```
hdfs haadmin –getServiceState nn1
```
### 查看 resourcemanager 是否活动
```
yarn rmadmin -getServiceState rm2
```