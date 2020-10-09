# HADOOP 遇到的坑
## 1. timeline 无法查看
在 yarn-site.xml 中正确配置 timelineserver 服务，可以查看官网的配置添加。

## 2. tez-ui 没有显示 - `未解决`


## 3. 队列设置后更新
```shell
yarn rmadmin -refreshQueues
```

## HA NameNode 宕机备用不启动
查看宕机namenode日志发现报错
```
2019-10-18 00:08:09,907 FATAL org.apache.hadoop.hdfs.server.namenode.FSEditLog: Error: starting log segment 68007 failed for required journal (JournalAndStream(mgr=QJM to [192.168.140.151:8485, 192.168.140.152:8485, 192.168.140.153:8485], stream=null))
java.io.IOException: Timed out waiting 20000ms for a quorum of nodes to respond.
    	at org.apache.hadoop.hdfs.qjournal.client.AsyncLoggerSet.waitForWriteQuorum(AsyncLoggerSet.java:137)
	at org.apache.hadoop.hdfs.qjournal.client.QuorumJournalManager.startLogSegment(QuorumJournalManager.java:408)
	at org.apache.hadoop.hdfs.server.namenode.JournalSet$JournalAndStream.startLogSegment(JournalSet.java:107)
	at org.apache.hadoop.hdfs.server.namenode.JournalSet$3.apply(JournalSet.java:222)
	at org.apache.hadoop.hdfs.server.namenode.JournalSet.mapJournalsAndReportErrors(JournalSet.java:393)
	at org.apache.hadoop.hdfs.server.namenode.JournalSet.startLogSegment(JournalSet.java:219)
	at org.apache.hadoop.hdfs.server.namenode.FSEditLog.startLogSegment(FSEditLog.java:1288)
	at org.apache.hadoop.hdfs.server.namenode.FSEditLog.rollEditLog(FSEditLog.java:1257)
	at org.apache.hadoop.hdfs.server.namenode.FSImage.rollEditLog(FSImage.java:1395)
	at org.apache.hadoop.hdfs.server.namenode.FSNamesystem.rollEditLog(FSNamesystem.java:5821)
	at org.apache.hadoop.hdfs.server.namenode.NameNodeRpcServer.rollEditLog(NameNodeRpcServer.java:1122)
	at org.apache.hadoop.hdfs.protocolPB.NamenodeProtocolServerSideTranslatorPB.rollEditLog(NamenodeProtocolServerSideTranslatorPB.java:142)
	at org.apache.hadoop.hdfs.protocol.proto.NamenodeProtocolProtos$NamenodeProtocolService$2.callBlockingMethod(NamenodeProtocolProtos.java:12025)
	at org.apache.hadoop.ipc.ProtobufRpcEngine$Server$ProtoBufRpcInvoker.call(ProtobufRpcEngine.java:616)
	at org.apache.hadoop.ipc.RPC$Server.call(RPC.java:982)
	at org.apache.hadoop.ipc.Server$Handler$1.run(Server.java:2217)
	at org.apache.hadoop.ipc.Server$Handler$1.run(Server.java:2213)
	at java.security.AccessController.doPrivileged(Native Method)
	at javax.security.auth.Subject.doAs(Subject.java:422)
	at org.apache.hadoop.security.UserGroupInformation.doAs(UserGroupInformation.java:1762)
	at org.apache.hadoop.ipc.Server$Handler.run(Server.java:2211)
2019-10-18 00:08:09,910 INFO org.apache.hadoop.util.ExitUtil: Exiting with status 1
2019-10-18 00:08:09,912 INFO org.apache.hadoop.hdfs.server.namenode.NameNode: SHUTDOWN_MSG:
```
百度后发现问题是
>namenode开启新日志段时，需要大多数journalnode写成功并响应，由于规定时间内只得到一个jn响应，active namenode认为异常然后自动退出服务;zkfailover捕捉到namenode异常，但由于2点39分zk同步日志耗时太长，session超时，进而导致zkfailover服务关闭，没有引发热切，之前的standby namenode依旧是standby,从而整个hadoop不可用

解决方法：

1. 在namenode对应的配置文件中调大写journanode超时参数（默认是20000ms）

    hdfs-site.xml添加
    ```xml
    <property>
        <name>dfs.qjournal.start-segment.timeout.ms</name>
        <value>90000</value>
    </property>
    <property>
        <name>dfs.qjournal.select-input-streams.timeout.ms</name>
        <value>90000</value>
    </property>
    <property>
        <name>dfs.qjournal.write-txns.timeout.ms</name>
        <value>90000</value>
    </property>
    ```
    core-site.xml添加
    ```xml
    <property>
        <name>ipc.client.connect.timeout</name>
        <value>90000</value>
    </property>
    ```
2. 关闭zk优先同步日志功能
    
    zoo.cfg
    ```shell
    forceSync=no
    ```


## namenode 已启动 ui访问 404
