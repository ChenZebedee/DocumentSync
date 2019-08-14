# Spark 基本原理与面试要点
## Spark 核心模块

![mF458I.jpg](https://s2.ax1x.com/2019/08/14/mF458I.jpg)

### Spark Core
Spark 的核心功能实现，包括：SparkContext 的初始化(DriverApplication 通过 SparkContext 提交)、部署模式、存储体系、任务提交与执行、计算引擎等

### Spark SQL
提供 SQL 处理能力，便于熟悉关系型数据库操作的工程师进行交互查询。

### Spark Streaming
提供流式计算处理能力，目前支持 Kafka、Flume、Twitter、MQTT、ZeroMq、Kinesis 和简单的 TCP 套接字等数据源

### GraphX
提供图计算处理能力

### MLlib
提供机器学习相关的统计、分类、回归、聚类等领域的多种算法实现

## Spark 重要概念
### Client
客户端进程，负责提交作业
### Application
提交一个作业就是一个Application，一个Application 只有一个 SparkContext
### Master
类似 Hadoop 的 NameNode
### Worker
类似 Hadoop 的 DataNode，执行 Master 发送的命令，来具体分配资源，并在分配的资源上执行任务
### Driver - JobTask
一个 Spark 在作业运行时会启动一个 Driver 进程，也就是作业的主进程，负责作业的解析、生成 Stage，并调度 Task 到 Executor 上
### Executor
真正执行作业的地方。Executor 分布在集群的 Worker 上，每个 Executor 接受 Driver 的命令加载和运行 Task，一个 Executor 可以运行一个或多个 Task
### SparkContext
是程序运行调度的核心，有高层调度器 DAGScheduler 划分程序的每个阶段，底层调度器 TaskScheduler 划分每个阶段的具体任务
### SchedulerBanked
管理整个集群中为正在运行的程序分配的计算资源 Executor
### DAG - Directed Acyclic Graph
有向无环图。Spark 实现了 DAG 计算模型，DAG 计算模式是指将一个任务按照计算规则分解为若干子任务，这些子任务之间根据逻辑关系构建成有向无环图
### RDD - Resilient Distributed Dataset
弹性分布数据集。是不可变的、Lazy 级的、粗粒度的(数据集级别的而不是单个数据级别的)数据集合，包含一个或多个数据切片，即 Partition
### DAGScheduler
负责高层调度，划分Stage并生成程序运行的有向无环图
### TaskScheduler
负责具体Stage内部的底层调度，具体Task的调度、容错等
### Job
（正在执行的叫ActiveJob）是Top-level的工作单元，每个Action算子都会触发一次Job，一个Job可能包含一个或多个Stage
### Stage
是用来计算中间结果的 Tasksets。Tasksets 中的 Task 逻辑对于同一 RDD 内的不同 Partitio n都一样。Stage 在 Shuffle 的地方产生，此时下一个 Stage 要用到上一个 Stage 的全部数据，所以要等上一个 Stage 全部执行完才能开始。Stage 有两种：
ShuffleMapStage 和 ResultStage，除了最后一个 Stage 是 ResultStage 外，其他的 Stage 都是 ShuffleMapStage。
ShuffleMapStage 会产生中间结果，以文件的方式保存在集群里，Stage 经常被不同的 Job 共享，前提是这些 Job 重用了同一个 RDD。
### Task
任务执行的工作单位，每个Task会被发送到一个节点上，每个Task对应RDD的一个Partition
### Taskset
划分的Stage会转换成一组相关联的任务集
### Transformation和Action
Transformation算子会由DAGScheduler划分到pipeline中，
是Lazy级别的不会触发任务的执行；Action算子会触发Job来执行pipeline中的运算

## Spark shuffle 过程
### Hash-Based Shuffle -- 根据 Map 个数计算
![mkVU5F.png](https://s2.ax1x.com/2019/08/14/mkVU5F.png)
上图每1个 Task 输出3份本地文件，这里有4个 Mapper Tasks，所以总共输出了4个 Tasks*3 个分类文件 = 12个本地小文件。

缺点：
    Shuffle前在磁盘上会产生海量的小文件，此时会产生大量耗时低效的 IO 操作 (因為产生过多的小文件）内存不够用，由于内存中需要保存海量文件操作句柄和临时信息，如果数据处理的规模比较庞大的话，内存不可承受，会出现 OOM 等问题

### Consolidated  Hash-Based Shuffle -- 根据核数计算
![mkVOPg.png](https://s2.ax1x.com/2019/08/14/mkVOPg.png)

上图每1个Task所在的进程中，分别写入共同进程中的3份本地文件，这里有4个Mapper Tasks，所以总共输出是 2个Cores x 3个分类文件 = 6个本地小文件。

缺点：
    如果 Reducer 端的并行任务或者是数据分片过多的话则 Core * Reducer Task 依旧过大，也会产生很多小文件。

### Sort-based Shuffle --根据分区计算
![mkZeMR.png](https://s2.ax1x.com/2019/08/14/mkZeMR.png)

1. 首先每个ShuffleMapTask不会为每个Reducer单独生成一个文件，相反，Sort-based Shuffle会把Mapper中每个ShuffleMapTask所有的输出数据Data只写到一个文件中。因为每个ShuffleMapTask中的数据会被分类，所以Sort-based Shuffle使用了index文件存储具体ShuffleMapTask输出数据在同一个Data文件中是如何分类的信息！
2. 基于Sort-base的Shuffle会在Mapper中的每一个ShuffleMapTask中产生两个文件：Data文件和Index文件，其中Data文件是存储当前Task的Shuffle输出的。而index文件中则存储了Data文件中的数据通过Partitioner的分类信息，此时下一个阶段的Stage中的Task就是根据这个Index文件获取自己所要抓取的上一个Stage中的ShuffleMapTask产生的数据的，Reducer就是根据index文件来获取属于自己的数据。

涉及问题：Sorted-based Shuffle：会产生 2*M(M代表了Mapper阶段中并行的Partition的总数量，其实就是ShuffleMapTask的总数量)个Shuffle临时文件。

Shuffle产生的临时文件的数量的变化依次为：
    Basic Hash Shuffle: M*R;
    Consalidate方式的Hash Shuffle: C*R;
    Sort-based Shuffle: 2*M;
