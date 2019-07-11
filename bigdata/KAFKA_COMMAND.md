# KAFKA COMMAND

## 启动
```bash
kafka-server-start.sh config/server.properties
```

## 关闭
```bash
kill -9 $(ps -ef|grep kafka |awk '{print $2}')
```

## 新建 Topic
```sh
kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic test
```

## Topic 列表
```sh
kafka-topics.sh --list --zookeeper localhost:2181
```

## 生产者
```bash
kafka-console-producer.sh --broker-list localhost:9092 --topic test
```

## 消费者
```bash
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test --from-beginning
```

## 删除分区
```bash
0. 关闭 kafka
1. 删除 Topic
kafka-topics.sh -delete -zookeeper [zookeeper server] -topic [topic name]
2. 删除 log 日志
rm -rf ${KAFKA_HOME}/logs/*
3. 删除ZK中的Topic记录
zkCli.sh -server ...
进入/admin/delete_topics目录下，找到删除的topic,删除对应的信息。
```


## 修改 offset
### 查看最小offset
```bash
 kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list 192.168.1.84:9092 -topic country_canal_test --time -2
```
### 查看最大 offset
```bash
kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list 192.168.1.84:9092 -topic country_canal_test --time -1
```
### 重置流程
```
./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group countryGET --describe
./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group countryGET --topic country_canal_out_imp --reset-offsets --to-earliest
./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group countryGET --topic country_canal_out_amp --reset-offsets --to-earliest
./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group countryGET --topic country_canal_out_imp --reset-offsets --to-earliest --execute
./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group countryGET --topic country_canal_out_amp --reset-offsets --to-earliest --execute
./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group countryGET --describe

```
