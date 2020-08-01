# KAFKA 官方文档学习
## 读前问题
### Q1:KAFKA是什么


### Q2:KAFKA怎么设计的

### Q3:KAFKA为什么这么设计


## 读后问题

## 1 入门
### 1.1 intorduction - 引语
ApacheKafka 是一个分布式流平台

流平台的关键功能：
* 发布和订阅记录流，类似于消息队列或企业消息传递系统
* 以容错的持久方式存储记录流
* 处理发生的记录流

应用：
* 建立实时流数据管道，以可靠的在系统或应用程序之间获取数据
* 构建实时流应用程序以转换或响应数据流

kafka的特点：
* Kafka 在一个或多个可以跨越多个数据中心的服务器上作为集群运行
* Kafka集群将记录流存储在称为topic的类别中
* 每个记录由一个键，一个值和一个时间戳组成
>Q:建是不是就是offset，值自定义，时间戳好像基本很少用到

Kafka 核心APi：
* Producer API -- 应用程序发布的记录流至一个或多个Kafka topic
* Consumer API -- 应用程序订阅一个或多个topic，并处理 producer 产生的由这些topic记录的数据流
* Streams API -- 充当流处理器，consumer从一个或多个topic获取输入流，然后产生一个producer向一个或多个topic构建输出流，有效的将数据重新分发至新topic中
* Connector API -- 构建和运行可以重复使用的consumer和producer连接topic给存在的应用程序或数据系统。例如：连接器连接数据库，可能获取表的所有变更
  
Kafka通过TPC协议进行通信。并且为Kafka提供了Java客户端，但是客户端支持多种语言


#### topic and logs ( logs 指存储的数据而不是日志 )
topic 是多用户的 一个 topic 可以有零个，一个或多个消费者

每个topic都会维护一个分区日志
![分区日志的维护](http://kafka.apache.org/20/images/log_anatomy.png)
每个分区有序，并且每条记录都分配一个唯一的offset用于各分区标识

