<!-- TOC -->

- [hadoop基本组成与原理](#hadoop%e5%9f%ba%e6%9c%ac%e7%bb%84%e6%88%90%e4%b8%8e%e5%8e%9f%e7%90%86)
  - [Hdfs:分布式文件存储系统 放数据的地方](#hdfs%e5%88%86%e5%b8%83%e5%bc%8f%e6%96%87%e4%bb%b6%e5%ad%98%e5%82%a8%e7%b3%bb%e7%bb%9f-%e6%94%be%e6%95%b0%e6%8d%ae%e7%9a%84%e5%9c%b0%e6%96%b9)
  - [NameNode 工作机制](#namenode-%e5%b7%a5%e4%bd%9c%e6%9c%ba%e5%88%b6)
  - [secondryNameNode 工作机制](#secondrynamenode-%e5%b7%a5%e4%bd%9c%e6%9c%ba%e5%88%b6)
  - [HDFS 读写工作过程：](#hdfs-%e8%af%bb%e5%86%99%e5%b7%a5%e4%bd%9c%e8%bf%87%e7%a8%8b)
  - [DataNode 工作机制](#datanode-%e5%b7%a5%e4%bd%9c%e6%9c%ba%e5%88%b6)
  - [MapReduce 工作流程](#mapreduce-%e5%b7%a5%e4%bd%9c%e6%b5%81%e7%a8%8b)
  - [shuffle 机制](#shuffle-%e6%9c%ba%e5%88%b6)
  - [MapTask 机制](#maptask-%e6%9c%ba%e5%88%b6)
  - [ReduceTask 机制](#reducetask-%e6%9c%ba%e5%88%b6)
  - [MapReduce：分布式并行计算框架 -- 处理数据的一个过程 主要目的也是处理数据](#mapreduce%e5%88%86%e5%b8%83%e5%bc%8f%e5%b9%b6%e8%a1%8c%e8%ae%a1%e7%ae%97%e6%a1%86%e6%9e%b6----%e5%a4%84%e7%90%86%e6%95%b0%e6%8d%ae%e7%9a%84%e4%b8%80%e4%b8%aa%e8%bf%87%e7%a8%8b-%e4%b8%bb%e8%a6%81%e7%9b%ae%e7%9a%84%e4%b9%9f%e6%98%af%e5%a4%84%e7%90%86%e6%95%b0%e6%8d%ae)
      - [当环形缓冲区的kvbuffer和kvmeta相遇了怎么办？](#%e5%bd%93%e7%8e%af%e5%bd%a2%e7%bc%93%e5%86%b2%e5%8c%ba%e7%9a%84kvbuffer%e5%92%8ckvmeta%e7%9b%b8%e9%81%87%e4%ba%86%e6%80%8e%e4%b9%88%e5%8a%9e)
    - [内存缓冲区设置：mapred.job.shuffle.input.buffer.percent](#%e5%86%85%e5%ad%98%e7%bc%93%e5%86%b2%e5%8c%ba%e8%ae%be%e7%bd%aemapredjobshuffleinputbufferpercent)
    - [内存到磁盘的设置：mapred.job.shuffle.merge.percent](#%e5%86%85%e5%ad%98%e5%88%b0%e7%a3%81%e7%9b%98%e7%9a%84%e8%ae%be%e7%bd%aemapredjobshufflemergepercent)
  - [Yarn：资源管理 任务调度平台 将mr1中的JobTracker进行了拆分--全局组件：Resourcemanager、应用组件：applicationMaster和日志管理：JobHistoryServer](#yarn%e8%b5%84%e6%ba%90%e7%ae%a1%e7%90%86-%e4%bb%bb%e5%8a%a1%e8%b0%83%e5%ba%a6%e5%b9%b3%e5%8f%b0-%e5%b0%86mr1%e4%b8%ad%e7%9a%84jobtracker%e8%bf%9b%e8%a1%8c%e4%ba%86%e6%8b%86%e5%88%86--%e5%85%a8%e5%b1%80%e7%bb%84%e4%bb%b6resourcemanager%e5%ba%94%e7%94%a8%e7%bb%84%e4%bb%b6applicationmaster%e5%92%8c%e6%97%a5%e5%bf%97%e7%ae%a1%e7%90%86jobhistoryserver)

<!-- /TOC -->
# hadoop基本组成与原理
## Hdfs:分布式文件存储系统 放数据的地方
组成：
1. namenode - 有且只有一个运行节点，接收用户指令。
2. datanode - 多个运行节点，数据存储的地方，可直接对数据进行处理
3. SecondryNameNode - 协助namenode合并元数据

## NameNode 工作机制
1. 用户上传数据的操作保存内存缓存中，同时往edits.log文件写入
2. edits.log文件是一个临时的日志文件，且随着edits.log文件达到一定大小之后会将数据写入到另一个edits.log2文件，因此会产生多个edits.log小文件
3. 多个edits.log小文件通过SecondaryNameNode（以下简称SN）节点最终保存在本地的fsimage文件中的
4. NN每隔一段时间向SN发送checkpoint请求（fsimage和edits.log的合并）
5. SN从NN上下载fsimage和edits.log文件，然后请求edits.log文件更改文件名为edits.new
6. SN将fsimage和edits.log在内存合并运算、整合，生成新的fsimage.checkpoint，通知NN
7. NN接到通知后从SN下载fsimage.checkpoint
8. NN将fsimage.checkpoint和edits.new文件改回原来的名字

## secondryNameNode 工作机制
解决的问题：当namenode宕机时，如果没有SNN就会丢失这次启动的时候所有对文件系统的操作，namenode启动时会获取这个文件系统的快照（fsimage），然后所有操作都会写到操作序列文件中（edits）。宕机后edits中记录的操作没有写到fsimage中，就会使元数据丢失，所以需要一个东西来进行定期或定量的快照处理，这样下次宕机后，启动还是能得到相对新的快照。
    
## HDFS 读写工作过程：
1. 读 client --> read --> namenode(元数据) --> datanode(数据文件) --> client读取数据，完事通知namenode关闭通道 --> read结束
2. 写 clinet --> write --> namenode(元数据) -心跳机制（目的：报告 block块情况）-> datanode(写入数据文件) --> client写完数据，通知namenode，持久化元数据，关闭流 --> wirte结束

## DataNode 工作机制
DN采用pipeline（管道）机制对数据进行副本的复制，客户端从提交到DN时只有一个副本，DN根据NN传来的各个主机形成一个管道，一旦有数据往DN的第一个节点传输数据时，DN就会往管道内的其他DN节点异步通过网络复制数据，只有当所有节点拷贝完成，这个管道才算成功，否则DN会向NN通知复制副本失败，NN接收到DN失败请求，会根据拷贝好的成功的节点和失败的节点做一个调整，重新形成新的管道（例如：有3个节点在传输，假如3个节点传输失败，这个管道就失败了，NN在重新选择的时候会将传输成功的第2个节点与其他非原来第3个节点的节点再次形成管理进行副本的复制）

![DataNode工作机制图](https://img-blog.csdn.net/20171114123754784?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvcXFfMjY0NDI1NTM=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center)

## MapReduce 工作流程
输入切片(input split) -> Map 阶段 -> conbiner 阶段 -> shuffle 阶段 -> Reduce 阶段 -> 输出到 HDFS


## shuffle 机制

## MapTask 机制

## ReduceTask 机制

## MapReduce：分布式并行计算框架 -- 处理数据的一个过程  主要目的也是处理数据

组成：
1. map：读取文件数据，对每行数据进行分割，并进行脏数据过滤，再组成<key，value>的样式既是map样式，最后放到hdfs上。
2. shuffle：将map输出的数据，整理一下，然后交给reduce，让reduce更方便整合。让同一个key的传到同一个reduce里。
```
    2.1 mapShuffle：map之后系统对数据的处理
    2.2 Partition（分区）：根据key的hash值对ReduceTask的数量取模得到的值作为Partition的值。--这个是系统的    个人定义Partition：自己定义Partitioner，用输入的数据的最大值除以系统ReduceTask的个数，的商作为分割边界，分割的数据最大可以为这个商的Partition数量-1倍，这样之后，partition是整体有序的。
    2.3 环形数据结构（kvbuffer）：一种存于内存中的，接收map输出数据的环形数据结构，其中有数据区域和索引区域两个部分，从一个点出发，数据存储向上增长，索引数据向下增长。
    2.4 关于kvbuffer、bufindex、kvmeta、kvindex的关系：
        2.4.1 kvbuffer是键值对就是<key, value>数据
        2.4.2 bufindex是数据的存放指针就是kvbuffer的索引
        2.4.3 kvmeta是存放索引数据的，以四元组的形式，其中包括value起始地址、key起始地址、partition值、value长度，占4个int长度
        2.4.4 kvindex是kvmeta的指针，从-4开始，每次存完向下增加4
        2.4.5 kvbuffer的大小可以通过io.sort.mb设置默认为100M，大小有限，满了就开始spill，默认80%开始spill可以通过io.sort.spill.percent设置开始spill的量最大为1
    2.5 sort（排序）：触发Spill时会先触发sort，将kvbuffer中的数据通过partition和key进行升序排序，但是操作的知识索引数据，即kvmeta，再深入一点是操作kvindex，最终数据会根据partition为单位聚集在一起，在partition内又按key排序。
    2.6 spill（溢写）：找到足够大的地方，并根据partition一个个的从kvbuffer中输出到创建的spill12.out文件中（每个partition数据叫段（segment））。
    2.7 对partition的索引：用三元组记录这个partition在这个文件中的起始位置、原始数据长度、压缩之后的数据长度。直接存于内存，存不下就找到足够大的地方创建spill12.out.index文件，写入。并且在文件中记录了crc32的校验数据（？）。
    2.8 combiner（组合）:在spill写之前调用，用于累加或取最大值之类的，只能查询操作，不能有增改删操作。
    2.9 Merge（合并）:当执行了多次spill时，会产生多个spill12.out和spill12.out.index文件，但是最终只要输出一个文件，需要merge操作来对这些文件进行合并，最终会产生两个文件，file.out和file.out.index文件。将partition对应的所有segment进行合并，变成一个完整的segment，分批进行，最小的先加。最终map的数据都是输出到磁盘上的。
    
    2.9 ReduceShuffle:reduce之前系统对数据的处理
    2.10 Copy（复制map输出的数据）：map任务结束后，通知父TaskTracker我更新了，爸爸就会通知爷爷JobTracker --就是心跳机制。JobTracker就记录了Map输出和TaskTracker的映射关系，Reduce定期向JobTracker获取Map的输出位置，只要一获取，就会复制到本地，进行下一步操作。
    2.11 Merge Sort(合并排序)：先放到内存缓冲区中，然后够放就在内存中处理了，不够就开始生成文件，然后copy完了就开始sort合并，最后输出一个整体的有序的数据块。
```
#### 当环形缓冲区的kvbuffer和kvmeta相遇了怎么办？
    取kvbuffer中剩余的空间的中间位置作为新的分界点，bufindex指针从这个分界点开始继续移动，而kvindex移到这个指正的-16的位置，双方继续放置数据。

### 内存缓冲区设置：mapred.job.shuffle.input.buffer.percent
    默认为JVM的70%
### 内存到磁盘的设置：mapred.job.shuffle.merge.percent
    默认为66%
3. reduce：读取map输出的数据，聚合key即(key,(value1,value2,value3...))>汇总value即(key,(value1+value2+value3+...))最终输出数据到hdfs上

## Yarn：资源管理 任务调度平台 将mr1中的JobTracker进行了拆分--全局组件：Resourcemanager、应用组件：applicationMaster和日志管理：JobHistoryServer

Yarn运行步骤（8步）：

![8步运行图解](https://cdn.sinaimg.cn.52ecy.cn/large/005BYqpgly1g59me7kuy1j310s0k9guh.jpg)

1. 用户向Yarn提交应用程序（MR的jar程序之类的），也就是一系列要完成的任务，其中包括ApplicationMaster（对这个任务负责的东西）程序，启动ApplicationMaster的命令，用户程序等；
2. ResourceManager为该应用程序分配一个Container（现在还没有分配其中的内容，既是空的Container）并与对应的NodeManager通信，要求它在这个Container中启动应用程序的ApplicationMaster；
3. ApplicationMaster首先向ResourceManager注册，这样可以直接通过RM查看应用程序运行的状态；然后它将为各个任务申请资源，并监控它的运行状态，直到结束，即重复4~7，需要注意的是，这里因为AM会将应用程序分为多个任务，因此为多个任务申请的资源不一定在一台机器上，所以步骤5中会有分支指向其他NodeManager；
4. AM采用轮询的方式通过RPC协议向RM申请和领取资源，ResourceScheduler将CPU、内存、磁盘封装成Container（不一定都在同一节点下）发给AM；
5. 一旦AM申请到资源后，便于对应的NodeManager（不一定是同一个）通信，要求它启动任务，并传递资源；
6. NM为任务设置好运行环境（包括环境变量，JAR包，二进制程序等）后，将任务启动命令写到一个脚本（Map Task/Reduce Task）中去，并运行该脚本任务，这里才是真正的开始执行任务；
7. 各个任务通过某个RPC协议向AM汇报自己的状态和进度（不同的NM下的同一个任务片段会向相同的AM汇报），以让AM随时掌握各个任务的运行状态，从而可以在任务失败的时候重启任务（在任务运行的过程中，用户可以随时通过RPC协议向AM查询应用程序当前的运行状态）；
8. 应用程序运行完成后，AM向RM注销并关闭自己。

个人理解Yarn运行步骤:

1. 用户提交（单独任务管理器，启动单独任务管理器的命令，任务运行的程序等）;
2. 资源管理就要给用户提交的东西分配一个空的容器，即Container，还要通知一下节点管理员，叫他在这个空的容器里启动单独的任务管理器;
3. 单独的任务管理器启动后，要先向资源管理器报道，即注册，这样才知道这个崽子吃的够不够，不够还要申请多给点他吃，崽子多了，就不在一个地了，就不一定在一个节点管理员那了，
4. 单独的任务管理器走RPC的路子向资源管理员申请领饭，然后资源调度员就会把CPU、内存、磁盘封装到容器里，给单独的任务管理器；
5. 单独的任务管理器领到饭了，就告诉节点管理员，叫他启动任务了，然后把领到的盒饭交给节点管理员；
6. 节点管理员拿了盒饭，给了机器，设置一下运行环境，然后用小本本记下来，然后运行这个小本本；
7. 每个任务孙子都走RPC的路子向单独的任务管理器汇报自己长大了没有，如果没有长大，那AM就会让他从新长；
8. 用户叫我们做的事都做好了，那单独的任务管理器就告诉资源管理员，我要去死了，没我啥事了；


Yarn 运行步骤(10步):

![10步运行图解](https://cdn.sinaimg.cn.52ecy.cn/large/005BYqpgly1g59mezancfj30mt0et0u7.jpg)

1. job client 向 ResourceManager提交执行job申请。
2. ResourceManager接收job请求，生成 job id ，返回 job id、staging工作目录等信息给job client。
3. client把资源jar等拷贝到staging工作目录（）
4. ResourceManager把job放入工作队列。
5. NodeManager从Resourcemanager队列中领取任务。
6. Resourcemanager根据job和NodeManager情况，计算出资源大小，并创建Container。
7. 创建MRAppMaster（如果计算框架是MR），运行在Container上。
8. MRAppMaster向ResourceManager注册。
9. MRAppMaster创建Map，Reduce task任务进程（yarn child）。
10. Map/Reduce任务完成，然后想Resourcemanager注销MRAppMaster进程。