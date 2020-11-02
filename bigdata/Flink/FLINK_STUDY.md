# Flink Study
## Flink 数据处理流程图
![数据处理流程图](https://flink.apache.org/img/flink-home-graphic.png)

## 下载安装

```shell
wget https://mirror.bit.edu.cn/apache/flink/flink-1.11.2/flink-1.11.2-bin-scala_2.12.tgz
tar -xf flink-1.11.2-bin-scala_2.12.tgz
cd flink-1.11.2
./bin/start-cluster.sh
./bin/flink run examples/streaming/WordCount.jar
tail log/flink-*-taskexecutor-*.out
```

## DataStream API 反欺诈系统

### 创建项目

```shell
mvn archetype:generate \
    -DarchetypeGroupId=org.apache.flink \
    -DarchetypeArtifactId=flink-walkthrough-datastream-scala \
    -DarchetypeVersion=1.11.2 \
    -DgroupId=xyz.19951106 \
    -DartifactId=frauddetection \
    -Dversion=0.1 \
    -Dpackage=spendreport \
    -DinteractiveMode=false
```

### 运行案例程序

#### 运行报错

```java
java.lang.ClassNotFoundException: org.apache.flink.streaming.api.functions.source.SourceFunction
```

解决

将 `<scope>provided</scope>` 修改成 `<scope>compile</scope>`