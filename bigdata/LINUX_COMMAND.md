# 目前在 83 上可能遇到的问题以及处理方式

## 服务宕机或占用资源过高

### hdfs 服务宕机
例如 namenode、SecondaryNameNode、datanode 宕机
可以通过 ```start-dfs.sh``` 启动服务

### yarn 服务宕机

例如 NodeManager、ResourceManager 服务宕机
可以通过 ```start-yarn.sh``` 启动服务

### hadoop job log 服务宕机

可以通过 ```mr-jobhistory-daemon.sh start historyserver``` 启动 JobHistoryServer 服务

### hive 服务宕机

可以通过 ``` ps -ef | grep hive ```
查看具体丢失哪个服务
伪分布主要启动了 HiveMetaStore 和 HiveServer2 服务
两个服务的启动命令分别为
```
nohup hive --service metastore 2>&1 > /opt/bigdata/hive-1.1.0-cdh5.15.1/logs/metastore.logs &
nohup hive --service hiveserver2 2>&1 >/opt/bigdata/hive-1.1.0-cdh5.15.1/logs/hivesever2.logs &
```

### hbase 服务宕机
hbase主要包括 Hmaster 和 HRegionServer

当 Hbase 服务宕机时，可以通过 ```start-hbase.sh``` 直接复现启动

或者通过相应的命令启动。如：
> hbase-dameon.sh start master 启动 Hmaster 
> hbase-dameons.sh start regionserver 启动 HRegionServer

### mysql
可以通过 workbench 下的 administration 里的 Client Connections 条目查看是否有存在异常连接或者重复语句，如果有，联系账户所有人，询问情况，并视情况能否进行杀死。

## 日志查看

### 导数据日志

1. 线上导数据入 83 库的执行日志在 /home/fsync/log/fsync.err
2. 83 库入 hive 的日志在 /home/.data/hive_table/logs 目录下，各库对应

### 服务日志
1. hadoop 日志在 192.168.5.33 上的 /opt/bigdata/hadoop-2.6.0-cdh5.15.1/logs 可以查看各个服务的日志，如果有服务宕机可以查看相应的服务日志
2. hive 执行 sql 日志可以在 33 上的 /opt/bigdata/hive-1.1.0-cdh5.15.1/logs 的 hivesever2.logs 文件查看
3. 其他各个组件的日志，都可在 /opt/bigdata 下的各组件文件夹内查看 log 或 logs 的相应日志信息

## kill 服务以及任务

### 服务的 kill
通过 ```jps``` 或 ``` ps -ef | grep mysql ``` 查看服务名对应的进程号，再通过 ```kill -9 ${进程号}``` 杀死服务，多用于 hive 重启

### job 任务 kill
通过 ```hadoop job -kill ${jobID}``` 来杀死 job 任务

### 有损坏块时的处理
报错： `The number of live datanodes 3 has reached the minimum number 0.`

解决办法： `hadoop dfsadmin -safemode leave && hdfs fsck / -delete`