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


### hbase-site.xml

### log4j.properties

### regionservers

### backup-masters