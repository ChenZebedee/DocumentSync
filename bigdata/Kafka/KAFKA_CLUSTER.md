# KAFKA 集群搭建
## 下载 KAFKA 与 SCALA
[KAFKA 1.0.0 下载地址](https://archive.apache.org/dist/kafka/1.0.0/kafka_2.12-1.0.0.tgz)

[SCALA 2.12.10 下载地址](https://downloads.lightbend.com/scala/2.12.10/scala-2.12.10.tgz)

## scala 搭建
自行百度

## kafka 搭建

### 以下用 root 用户操作
1. 修改 /etc/profile 文件，添加如下内容
```
#SCALA
export SCALA_HOME=/usr/local/scala
export PATH=$PATH:$SCALA_HOME/bin

#KAFKA
export KAFKA_HOME=/opt/bigdata/kafka
export PATH=$PATH:$KAFKA_HOME/bin
```

### 以下用 hadoop 用户操作

1. 解压 kafka `tar xf kafka_2.12-1.0.0.tgz`
2. 将 kafka 文件夹移动到 hadoop 用户的个人目录下的 bigdata 目录
3. 通过 ln 进行软连接到 /opt/bigdata 目录下 
```shell
ln -s ${user_home}/bigdata/kafka_2.12-1.0.0 /opt/bigdata/kafka
```
每台机器都重复以上步骤

## kafka 配置
### server.properties 核心配置
1. broker.id --每台机器配置各自的 ID 不能相同
2. listeners --根据规则配置每台自己的主机名或者 IP 地址
3. log.dirs --配置目录地址
4. zookeeper.connect --配置 zookeeper 地址，集群用 , 分隔开
5. delete.topic.enable --配置删除 topic 则删除数据

完整配置案例：
```shell
broker.id=0
listeners=PLAINTEXT://hadoop01:9092
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/opt/bigdata/kafka/logs
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
message.max.byte=5242880
default.replication.factor=2
replica.fetch.max.bytes=5242880
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=hadoop01:2181,hadoop02:2181,hadoop03:2181
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
group.min.session.timeout.ms=6000
group.max.session.timeout.ms=1000000
delete.topic.enable=true
```